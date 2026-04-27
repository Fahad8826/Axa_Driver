import 'package:axa_driver/Home/model/home_model.dart';
import 'package:axa_driver/core/services/app_pref.dart';
import 'package:axa_driver/core/network/dioclient.dart';
import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeController extends GetxController {
  final Dio _dio = DioClient.dio;

  final isLoading = true.obs;
  final error = ''.obs;

  final Rx<TodaySummaryModel?> summary = Rx(null);
  final Rx<OrderModel?> nearestOrder = Rx(null);
  final nearestOrderMessage = 'No active delivery right now'.obs;
  final RxList<OrderModel> todayOrders = <OrderModel>[].obs;
  String? _nextUrl;
  bool get hasMoreOrders => _nextUrl != null;
  final isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTodaySummary();
  }

  // ← ADD THIS
  @override
  void onReady() {
    super.onReady();
    _checkBatteryPermission();
  }

  Future<void> fetchTodaySummary() async {
    try {
      isLoading(true);
      error('');

      // Fetch all three concurrently
      final responses = await Future.wait([
        _dio.get('/api/driver/today-summary/'),
        _dio.get('/api/driver/nearest-order/'),
        _dio.get('/api/driver/today-orders/'),
      ]);

      final summaryResponse = responses[0];
      final nearestResponse = responses[1];
      final ordersResponse = responses[2];

      // 1. Summary
      summary.value = TodaySummaryModel.fromJson(
        summaryResponse.data as Map<String, dynamic>,
      );

      // 2. Nearest order
      if (nearestResponse.data != null &&
          nearestResponse.data is Map<String, dynamic>) {
        final data = nearestResponse.data as Map<String, dynamic>;
        if (data.containsKey('message')) {
          // API returned a message (e.g. "No orders available") instead of order data
          nearestOrderMessage.value =
              data['message'] as String? ?? 'No active delivery right now';
          nearestOrder.value = null;
        } else {
          nearestOrder.value = OrderModel.fromJson(data);
          nearestOrderMessage.value = 'No active delivery right now';
        }
      } else {
        nearestOrder.value = null;
        nearestOrderMessage.value = 'No active delivery right now';
      }

      // 3. Today's orders (paginated response)
      if (ordersResponse.data != null && ordersResponse.data is Map<String, dynamic>) {
        final data = ordersResponse.data as Map<String, dynamic>;
        _nextUrl = data['next'] as String?;
        final results = data['results'] as List<dynamic>? ?? [];
        todayOrders.value = results
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        todayOrders.clear();
        _nextUrl = null;
      }
    } catch (e) {
      error(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadMoreOrders() async {
    if (_nextUrl == null || isLoadingMore.value) return;

    try {
      isLoadingMore(true);
      final response = await _dio.getUri(Uri.parse(_nextUrl!));
      final data = response.data as Map<String, dynamic>;
      _nextUrl = data['next'] as String?;

      final results = data['results'] as List<dynamic>? ?? [];
      todayOrders.addAll(results.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)));
    } catch (e) {
      debugPrint('Load more orders error: $e');
    } finally {
      isLoadingMore(false);
    }
  }

  // ── Battery permission ─────────────────────────────────────────────────────
  Future<void> _checkBatteryPermission() async {
    // If already granted, no need to show
    if (await Permission.ignoreBatteryOptimizations.isGranted) return;
    
    // If we already showed this dialog once, don't annoy the user again
    if (await AppPrefs.isBatteryDialogShown()) return;

    await Future.delayed(const Duration(milliseconds: 800));
    _showBatteryDialog();
  }

  void _showBatteryDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(height: 14),
              Text('Keep Tracking Active', style: AppTextStyles.headingSmall),
              const SizedBox(height: 8),
              Text(
                'To ensure your location is tracked during deliveries, '
                'please allow unrestricted background activity.',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              _bullet('Do not force-close the app'),
              _bullet('Allow battery optimization exemption'),
              _bullet('Keep app running while on delivery'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        Get.back();
                        await AppPrefs.setBatteryDialogShown();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: AppColors.divider),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        'Later',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        await AppPrefs.setBatteryDialogShown();
                        await Permission.ignoreBatteryOptimizations.request();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Allow', style: AppTextStyles.buttonSmall),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _bullet(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        const Icon(
          Icons.check_circle_outline_rounded,
          size: 15,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
      ],
    ),
  );
}
