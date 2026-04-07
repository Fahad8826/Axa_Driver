import 'package:axa_driver/core/network/dioclient.dart';
import 'package:axa_driver/navigation/model/order_detail_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NavigationController extends GetxController {
  final Dio _dio = DioClient.dio;

  // ── Args passed from calling screen ───────────────────────────────────────
  late final int orderId;
  late final double destLat;
  late final double destLng;

  // ── State ─────────────────────────────────────────────────────────────────
  final isLoading = true.obs;
  final error = ''.obs;
  final Rx<OrderDetailModel?> orderDetail = Rx(null);

  // ── Map ───────────────────────────────────────────────────────────────────
  GoogleMapController? mapController;
  final currentPosition = Rx<LatLng?>(null);

  // FIX: Use RxSet instead of plain Set wrapped in obs to avoid full map rebuilds
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;

  // ── Stats ─────────────────────────────────────────────────────────────────
  final distance = '—'.obs;
  final duration = '—'.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    orderId = args['orderId'] as int;
    destLat = (args['destLat'] as num).toDouble();
    destLng = (args['destLng'] as num).toDouble();
    _init();
  }

  Future<void> _init() async {
    // FIX: Run location fetch and order fetch concurrently to reduce wait time
    await Future.wait([
      _fetchLocation(),
      fetchOrderDetail(),
    ]);

    // These depend on both location + order being ready
    _buildMarkers();
    await _fetchRoadPath();

    // FIX: Fit bounds AFTER location is confirmed and map may already be ready
    _fitBoundsIfReady();
  }

  // ── Fetch current GPS location ────────────────────────────────────────────
  Future<void> _fetchLocation() async {
    try {
      // FIX: Use ONLY Geolocator for permissions — do NOT mix permission_handler
      // with Geolocator. Mixing them causes crashes on Android and iOS.
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permission denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permission permanently denied.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      currentPosition.value = LatLng(position.latitude, position.longitude);

      // Straight-line distance as a quick placeholder
      final distInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        destLat,
        destLng,
      );
      distance.value = '${(distInMeters / 1000).toStringAsFixed(1)} km';
      final mins = (distInMeters / 1000) / 40 * 60;
      duration.value = '${mins.round()} min';
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  // ── Fetch order detail from API ───────────────────────────────────────────
  Future<void> fetchOrderDetail() async {
    try {
      isLoading(true);
      error('');
      final response = await _dio.get('/api/driver/order/$orderId/');
      orderDetail.value = OrderDetailModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      error(e.message ?? 'Failed to load order details.');
    } catch (_) {
      error('Something went wrong.');
    } finally {
      isLoading(false);
    }
  }

  // ── Build map markers ─────────────────────────────────────────────────────
  void _buildMarkers() {
    final dest = LatLng(destLat, destLng);
    final newMarkers = <Marker>{};

    newMarkers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: dest,
        infoWindow: InfoWindow(
          title: orderDetail.value?.customerName ?? 'Destination',
          snippet: orderDetail.value?.customerAddress,
        ),
      ),
    );

    if (currentPosition.value != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('current'),
          position: currentPosition.value!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    // FIX: Assign all at once to trigger only one rebuild
    markers.assignAll(newMarkers);
  }

  // ── Fetch the real road path ──────────────────────────────────────────────
  Future<void> _fetchRoadPath() async {
  final origin = currentPosition.value;
  if (origin == null) return;

  try {
    final apiKey = dotenv.env['GOOGLE_MAPS_KEY'] ?? '';
    if (apiKey.isEmpty) {
      _buildFallbackPolyline(origin);
      return;
    }

    // v3.x: key goes in the constructor, not the call
    final polylinePoints = PolylinePoints(apiKey: apiKey);

    final result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(origin.latitude, origin.longitude),
        destination: PointLatLng(destLat, destLng),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      polylines.assignAll({
        Polyline(
          polylineId: const PolylineId('route'),
          color: const Color(0xFF1976D2),
          width: 5,
          points: result.points
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList(),
        ),
      });

      // v3.x field names (same as v2.x for legacy result)
      if (result.totalDistanceValue != null && result.totalDistanceValue! > 0) {
        distance.value =
            '${(result.totalDistanceValue! / 1000).toStringAsFixed(1)} km';
      }
      if (result.totalDurationValue != null && result.totalDurationValue! > 0) {
        duration.value = '${(result.totalDurationValue! / 60).round()} min';
      }
    } else {
      _buildFallbackPolyline(origin);
    }
  } catch (e) {
    debugPrint('Polyline fetch error: $e');
    _buildFallbackPolyline(origin);
  }
}

  // ── Straight-line fallback polyline ───────────────────────────────────────
  void _buildFallbackPolyline(LatLng origin) {
    polylines.assignAll({
      Polyline(
        polylineId: const PolylineId('route'),
        color: const Color(0xFF1976D2),
        width: 4,
        patterns: [
          // Dashed to signal it's not a real road route
          PatternItem.dash(12),
          PatternItem.gap(6),
        ],
        points: [origin, LatLng(destLat, destLng)],
      ),
    });
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // FIX: Fit bounds here — by the time the map is ready _init() has
    // completed (both futures resolved), so currentPosition is populated.
    _fitBoundsIfReady();
  }

  // FIX: Extracted to a safe guard that can be called from both
  // onMapCreated (map ready before data) and end of _init (data ready before map)
  void _fitBoundsIfReady() {
    final origin = currentPosition.value;
    if (origin == null || mapController == null) return;

    final dest = LatLng(destLat, destLng);

    final sw = LatLng(
      origin.latitude < dest.latitude ? origin.latitude : dest.latitude,
      origin.longitude < dest.longitude ? origin.longitude : dest.longitude,
    );
    final ne = LatLng(
      origin.latitude > dest.latitude ? origin.latitude : dest.latitude,
      origin.longitude > dest.longitude ? origin.longitude : dest.longitude,
    );

    mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: sw, northeast: ne),
        80,
      ),
    );
  }

  void centerOnDestination() {
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(destLat, destLng), 15),
    );
  }

  // ── Launch external navigation ────────────────────────────────────────────
  Future<void> launchGoogleMaps() async {
    final url = Uri.parse('google.navigation:q=$destLat,$destLng&mode=d');
    final fallbackUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$destLat,$destLng&travelmode=driving',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else if (await canLaunchUrl(fallbackUrl)) {
      await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void onClose() {
    mapController?.dispose();
    super.onClose();
  }
}