
import 'dart:async';

import 'package:axa_driver/core/network/dioclient.dart';
import 'package:axa_driver/navigation/model/order_detail_model.dart';
import 'package:axa_driver/orders/services/order_picked.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:axa_driver/core/services/location_service.dart';

class NavigationController extends GetxController {
  final Dio _dio = DioClient.dio;
  bool _isDisposed = false;

  // ── Args ───────────────────────────────────────────────────────────────────
  late final int orderId;
  late final String orderType; // ← declared here

  // Fallback coords from args (used until order loads)
  double? _argLat;
  double? _argLng;

  // Final destination — set from order model once loaded
  double? _destLat;
  double? _destLng;

  // ── State ──────────────────────────────────────────────────────────────────
  final isLoading = true.obs;
  final isRouteLoading = false.obs;
  final error = ''.obs;
  final Rx<OrderDetailModel?> orderDetail = Rx(null);

  // ── Map ────────────────────────────────────────────────────────────────────
  GoogleMapController? mapController;
  final currentPosition = Rx<LatLng?>(null);
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;

  // ── Stats ──────────────────────────────────────────────────────────────────
  final distance = '—'.obs;
  final duration = '—'.obs;

  // ── Pick up state ──────────────────────────────────────────────────────────
final isMarkingPicked = false.obs;
final isPickedUp = false.obs;

  // ── Live GPS stream ────────────────────────────────────────────────────────
  StreamSubscription<Position>? _positionStream;

  @override
  void onInit() {
    super.onInit();
    // ── Read ALL args here, once ──────────────────────────────────────────
    final args = Get.arguments as Map<String, dynamic>;
    orderId = args['orderId'] as int;
    orderType = args['orderType'] as String? ?? 'today';
    _argLat = (args['destLat'] as num?)?.toDouble();
    _argLng = (args['destLng'] as num?)?.toDouble();

    _init();

    Future.delayed(const Duration(seconds: 2), () async {
      try {
        await startLocationService();
      } catch (e) {
        debugPrint('[Nav] Location service start failed: $e');
      }
    });
  }

  Future<void> _init() async {
    // 1. Fetch order detail first — so we can get real destination coords
    await fetchOrderDetail();
    if (_isDisposed) return;

    // 2. Resolve destination: prefer model coords over arg fallback
    final order = orderDetail.value;
    if (order != null && order.customerLat != 0.0 && order.customerLng != 0.0) {
      _destLat = order.customerLat;
      _destLng = order.customerLng;
      debugPrint('[Nav] Destination from order model: $_destLat, $_destLng');
    } else if (_argLat != null && _argLng != null) {
      _destLat = _argLat;
      _destLng = _argLng;
      debugPrint('[Nav] Destination from args fallback: $_destLat, $_destLng');
    } else {
      error('Could not determine delivery destination.');
      isLoading(false);
      debugPrint('[Nav] ❌ No valid destination found');
      return;
    }

    // 3. Get current GPS position
    await _fetchLocation();
    if (_isDisposed) return;

    // 4. Build markers + route
    _buildMarkers();
    await _fetchRoute();
    if (_isDisposed) return;
    _fitBoundsIfReady();

    // 5. Start live GPS stream for driver position updates
    _startPositionStream();
  }

  // ── Live GPS Stream ────────────────────────────────────────────────────────
  void _startPositionStream() {
    _positionStream?.cancel();
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 15,
      ),
    ).listen(
      (pos) {
        if (_isDisposed) return;
        final newPos = LatLng(pos.latitude, pos.longitude);
        currentPosition.value = newPos;
        _buildMarkers();
        debugPrint('[Nav] 📍 Position updated: ${pos.latitude}, ${pos.longitude}');
      },
      onError: (e) {
        debugPrint('[Nav] Position stream error: $e');
      },
    );
    debugPrint('[Nav] ✅ Live GPS stream started');
  }

  // ── Mark as Picked ─────────────────────────────────────────────────────────
Future<void> markAsPicked() async {
  if (isMarkingPicked.value || isPickedUp.value) return; // ← double guard
  try {
    isMarkingPicked(true);
    final success = await OrderService.markAsPicked(orderId);
    if (success) {
      isPickedUp(true); // ← set once, never reset
    }
  } finally {
    isMarkingPicked(false);
  }
}

  // ── GPS (initial fix) ──────────────────────────────────────────────────────
  Future<void> _fetchLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        debugPrint('[Nav] GPS service disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 15));

      currentPosition.value = LatLng(position.latitude, position.longitude);

      if (_destLat != null && _destLng != null) {
        final distInMeters = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          _destLat!,
          _destLng!,
        );
        distance.value = '${(distInMeters / 1000).toStringAsFixed(1)} km';
        duration.value = '${((distInMeters / 1000) / 40 * 60).round()} min';
      }
    } catch (e) {
      debugPrint('[Nav] Location error: $e');
    }
  }

  // ── Order detail ───────────────────────────────────────────────────────────
  Future<void> fetchOrderDetail() async {
    try {
      isLoading(true);
      error('');

      // Pick correct endpoint based on order type
      final endpoint = orderType == 'nearest'
          ? '/api/driver/nearest-order/$orderId/'
          : '/api/driver/today-orders/$orderId/';

      final response = await _dio.get(endpoint);
      orderDetail.value = OrderDetailModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      debugPrint('[Nav] ✅ Order loaded: ${orderDetail.value?.customerName}');
    } on DioException catch (e) {
      error(e.message ?? 'Failed to load order details.');
    } catch (_) {
      error('Something went wrong.');
    } finally {
      isLoading(false);
    }
  }

  // ── Markers ────────────────────────────────────────────────────────────────
  void _buildMarkers() {
    if (_destLat == null || _destLng == null) return;

    final newMarkers = <Marker>{
      Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(_destLat!, _destLng!),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: orderDetail.value?.customerName ?? 'Destination',
          snippet: orderDetail.value?.customerAddress,
        ),
      ),
    };

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

    markers.assignAll(newMarkers);
  }

  // ── Google Maps route ──────────────────────────────────────────────────────
  Future<void> _fetchRoute() async {
    final origin = currentPosition.value;
    if (origin == null || _destLat == null || _destLng == null) {
      debugPrint('[Nav] Skipping route fetch — missing origin or destination');
      return;
    }

    final apiKey = dotenv.env['GOOGLE_MAPS_KEY'] ?? '';
    if (apiKey.isEmpty) {
      debugPrint('[Nav] No Google Maps API key found in .env');
      return;
    }

    try {
      isRouteLoading(true);
      debugPrint('[Nav] Fetching route: ${origin.latitude},${origin.longitude} → $_destLat,$_destLng');

      final result = await PolylinePoints(apiKey: apiKey).getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(_destLat!, _destLng!),
          mode: TravelMode.driving,
        ),
      );

      if (_isDisposed) return;

      final err = result.errorMessage ?? '';
      if (err.isNotEmpty) {
        debugPrint('[Nav] Route error: $err');
        return;
      }

      if (result.points.isEmpty) {
        debugPrint('[Nav] No route points returned');
        return;
      }

      polylines.assignAll({
        Polyline(
          polylineId: const PolylineId('route'),
          color: const Color(0xFF1A73E8),
          width: 5,
          points: result.points.map((p) => LatLng(p.latitude, p.longitude)).toList(),
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      });

      if ((result.totalDistanceValue ?? 0) > 0) {
        distance.value = '${(result.totalDistanceValue! / 1000).toStringAsFixed(1)} km';
      }
      if ((result.totalDurationValue ?? 0) > 0) {
        duration.value = '${(result.totalDurationValue! / 60).round()} min';
      }

      debugPrint('[Nav] ✅ Route loaded: ${distance.value}, ${duration.value}');
    } catch (e) {
      debugPrint('[Nav] Route fetch error: $e');
    } finally {
      isRouteLoading(false);
    }
  }

  // ── Refresh route ──────────────────────────────────────────────────────────
  Future<void> refreshRoute() async {
    debugPrint('[Nav] 🔄 Refreshing route...');
    polylines.clear();
    distance.value = '—';
    duration.value = '—';

    await _fetchLocation();
    if (_isDisposed) return;

    _buildMarkers();
    await _fetchRoute();
    if (_isDisposed) return;

    _fitBoundsIfReady();
    debugPrint('[Nav] ✅ Route refreshed');
  }

  // ── Map callbacks ──────────────────────────────────────────────────────────
  void onMapCreated(GoogleMapController controller) {
    if (_isDisposed) {
      controller.dispose();
      return;
    }
    mapController = controller;
    _fitBoundsIfReady();
  }

  void _fitBoundsIfReady() {
    final origin = currentPosition.value;
    if (_isDisposed || origin == null || mapController == null || _destLat == null || _destLng == null) return;

    final dest = LatLng(_destLat!, _destLng!);
    mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            origin.latitude < dest.latitude ? origin.latitude : dest.latitude,
            origin.longitude < dest.longitude ? origin.longitude : dest.longitude,
          ),
          northeast: LatLng(
            origin.latitude > dest.latitude ? origin.latitude : dest.latitude,
            origin.longitude > dest.longitude ? origin.longitude : dest.longitude,
          ),
        ),
        80,
      ),
    );
  }

  void centerOnDriver() {
    final pos = currentPosition.value;
    if (_isDisposed || mapController == null || pos == null) return;
    mapController!.animateCamera(CameraUpdate.newLatLngZoom(pos, 16));
  }

  void centerOnDestination() {
    if (_isDisposed || mapController == null || _destLat == null) return;
    mapController!.animateCamera(CameraUpdate.newLatLngZoom(LatLng(_destLat!, _destLng!), 15));
  }

  // ── Launch Google Maps ─────────────────────────────────────────────────────
  Future<void> launchGoogleMaps() async {
    if (_destLat == null || _destLng == null) return;

    final url = Uri.parse('google.navigation:q=$_destLat,$_destLng&mode=d');
    final fallback = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$_destLat,$_destLng&travelmode=driving',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else if (await canLaunchUrl(fallback)) {
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void onClose() {
    _isDisposed = true;
    _positionStream?.cancel();
    _positionStream = null;
    mapController?.dispose();
    mapController = null;
    super.onClose();
  }
}