import 'dart:async';

import 'package:axa_driver/core/network/dioclient.dart';

import 'package:axa_driver/core/theme/utils/snackbars.dart';
import 'package:axa_driver/orders/model/orders_model.dart';
import 'package:axa_driver/orders/services/order_picked.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;

class OrdersController extends GetxController {
  final Dio _dio = DioClient.dio;

  // ── List state ─────────────────────────────────────────────────────────────
  final RxList<OrdersModel> orders = <OrdersModel>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final isRefreshing = false.obs;
  final error = ''.obs;

  // ── Pagination ─────────────────────────────────────────────────────────────
  String? _nextUrl;
  bool get hasMore => _nextUrl != null;

  // ── Search & Filter ────────────────────────────────────────────────────────
  final searchQuery = ''.obs;
  final selectedStatus = ''.obs;
  final ScrollController scrollController = ScrollController();

  static const List<String> statusOptions = [
    'all', 'assigned', 'pending', 'delivered', 'cancelled',
  ];

  // ── Auto-refresh ───────────────────────────────────────────────────────────
  Timer? _pollingTimer;
  static const Duration _pollInterval = Duration(seconds: 30);

  // ── Detail state ───────────────────────────────────────────────────────────
  final Rx<OrdersModel?> orderDetail = Rx(null);
  final isDetailLoading = false.obs;
  final detailError = ''.obs;

  // ── Delivery Proof ─────────────────────────────────────────────────────────
  final isUploadingProof = false.obs;

  // ── Pick up state ──────────────────────────────────────────────────────────
  final isMarkingPicked = false.obs;
  final isPickedUp = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders(reset: true);
    scrollController.addListener(_onScroll);
    _startPolling();
  }

  @override
  void onClose() {
    _stopPolling();
    scrollController.dispose();
    super.onClose();
  }

  // ── Polling ────────────────────────────────────────────────────────────────
  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(_pollInterval, (_) => _silentRefresh());
    debugPrint('[Orders] ✅ Auto-refresh started every ${_pollInterval.inSeconds}s');
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    debugPrint('[Orders] 🛑 Auto-refresh stopped');
  }

  Future<void> _silentRefresh() async {
    if (isLoading.value || isLoadingMore.value || isRefreshing.value) return;
    try {
      isRefreshing(true);
      debugPrint('[Orders] 🔄 Silent refresh...');
      final response = await _dio.get('/api/driver/orders/', queryParameters: _buildParams());
      final data = response.data as Map<String, dynamic>;
      _nextUrl = data['next'] as String?;
      final results = (data['results'] as List<dynamic>? ?? [])
          .map((e) => OrdersModel.fromJson(e as Map<String, dynamic>))
          .toList();
      if (_hasChanges(results)) {
        orders.assignAll(results);
        debugPrint('[Orders] ✅ List updated with new data');
      } else {
        debugPrint('[Orders] ℹ️ No changes detected');
      }
    } catch (e) {
      debugPrint('[Orders] ⚠️ Silent refresh failed: $e');
    } finally {
      isRefreshing(false);
    }
  }

  bool _hasChanges(List<OrdersModel> incoming) {
    if (incoming.length != orders.length) return true;
    for (int i = 0; i < incoming.length; i++) {
      if (incoming[i].id != orders[i].id || incoming[i].status != orders[i].status) return true;
    }
    return false;
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore.value && hasMore) {
      _loadMore();
    }
  }

  Map<String, dynamic> _buildParams({int page = 1}) {
    final params = <String, dynamic>{'page': page};
    if (searchQuery.value.isNotEmpty) params['search'] = searchQuery.value;
    if (selectedStatus.value.isNotEmpty && selectedStatus.value != 'all') {
      params['status'] = selectedStatus.value;
    }
    return params;
  }

  Future<void> fetchOrders({bool reset = false}) async {
    try {
      if (reset) {
        isLoading(true);
        error('');
        orders.clear();
        _nextUrl = null;
      }
      final response = await _dio.get('/api/driver/orders/', queryParameters: _buildParams());
      final data = response.data as Map<String, dynamic>;
      _nextUrl = data['next'] as String?;
      final results = (data['results'] as List<dynamic>? ?? [])
          .map((e) => OrdersModel.fromJson(e as Map<String, dynamic>))
          .toList();
      if (reset) {
        orders.assignAll(results);
      } else {
        orders.addAll(results);
      }
    } on DioException catch (e) {
      error(e.response?.data?['message'] ?? e.message ?? 'Failed to load orders');
    } catch (e) {
      error('Something went wrong while loading orders');
    } finally {
      isLoading(false);
    }
  }

  Future<void> onRefresh() async {
    _stopPolling();
    await fetchOrders(reset: true);
    _startPolling();
  }

  Future<void> _loadMore() async {
    if (_nextUrl == null) return;
    try {
      isLoadingMore(true);
      final response = await _dio.getUri(Uri.parse(_nextUrl!));
      final data = response.data as Map<String, dynamic>;
      _nextUrl = data['next'] as String?;
      final results = (data['results'] as List<dynamic>? ?? [])
          .map((e) => OrdersModel.fromJson(e as Map<String, dynamic>))
          .toList();
      orders.addAll(results);
    } catch (e) {
      debugPrint('Load more error: $e');
    } finally {
      isLoadingMore(false);
    }
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    fetchOrders(reset: true);
  }

  void onStatusSelected(String status) {
    selectedStatus.value = status == 'all' ? '' : status;
    fetchOrders(reset: true);
  }

  Future<void> fetchOrderDetail(int id) async {
    try {
      isDetailLoading(true);
      detailError('');
      orderDetail.value = null;
      // ── Reset picked flag when loading a new order ──────────────────────
      isPickedUp(false);
      final response = await _dio.get('/api/driver/order/$id/');
      orderDetail.value = OrdersModel.fromJson(response.data as Map<String, dynamic>);
      // ── If order is already beyond assigned, mark as picked locally ──────
      final status = orderDetail.value?.status.toLowerCase() ?? '';
      if (status == 'picked' || status == 'delivered' || status == 'cancelled') {
        isPickedUp(true);
      }
    } catch (e) {
      detailError(e.toString());
    } finally {
      isDetailLoading(false);
    }
  }

  // ── Mark as Picked ─────────────────────────────────────────────────────────
  Future<void> markAsPicked(int orderId) async {
    if (isMarkingPicked.value || isPickedUp.value) return; // double guard
    try {
      isMarkingPicked(true);
      final success = await OrderService.markAsPicked(orderId);
      if (success) {
        isPickedUp(true); // set once, never reset until new order loads
        await fetchOrderDetail(orderId); // refresh detail silently
        _silentRefresh(); // refresh list in background
      }
    } finally {
      isMarkingPicked(false);
    }
  }

  // ── Upload Delivery Proof ──────────────────────────────────────────────────
  Future<void> uploadDeliveryProof(int orderId, String imagePath) async {
    try {
      isUploadingProof(true);
      final formData = FormData.fromMap({
        'order_id': orderId.toString(),
        'delivery_proof_image': await MultipartFile.fromFile(imagePath),
      });
      final response = await _dio.post('/api/driver/delivery-proof/', data: formData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        AppFeedback.success('Delivery proof uploaded successfully');
        await fetchOrderDetail(orderId);
        _silentRefresh();
      } else {
        AppFeedback.error('Failed to upload delivery proof');
      }
    } on DioException catch (e) {
      AppFeedback.error(e.response?.data?['message'] ?? e.message ?? 'Upload failed');
    } catch (e) {
      AppFeedback.error('Something went wrong while uploading');
    } finally {
      isUploadingProof(false);
    }
  }
}