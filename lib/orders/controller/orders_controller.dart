
import 'package:axa_driver/core/network/dioclient.dart';
import 'package:axa_driver/orders/model/orders_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrdersController extends GetxController {
  final Dio _dio = DioClient.dio;

  // ── List state ────────────────────────────────────────────────────────────
  final RxList<OrdersModel> orders = <OrdersModel>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final error = ''.obs;

  // ── Pagination ────────────────────────────────────────────────────────────
  String? _nextUrl;
  bool get hasMore => _nextUrl != null;

  // ── Search & Filter ───────────────────────────────────────────────────────
  final searchQuery = ''.obs;
  final selectedStatus = ''.obs; // '' = all
  final ScrollController scrollController = ScrollController();

  static const List<String> statusOptions = [
    'all',
    'assigned',
    'pending',
    'delivered',
    'cancelled',
  ];

  // ── Detail state ──────────────────────────────────────────────────────────
  final Rx<OrdersModel?> orderDetail = Rx(null);
  final isDetailLoading = false.obs;
  final detailError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders(reset: true);
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore.value &&
        hasMore) {
      _loadMore();
    }
  }

  // ── Build query params ────────────────────────────────────────────────────
  Map<String, dynamic> _buildParams({int page = 1}) {
    final params = <String, dynamic>{'page': page};
    if (searchQuery.value.isNotEmpty) {
      params['search'] = searchQuery.value;
    }
    if (selectedStatus.value.isNotEmpty &&
        selectedStatus.value != 'all') {
      params['status'] = selectedStatus.value;
    }
    return params;
  }

  // ── Fetch (reset) ─────────────────────────────────────────────────────────
  Future<void> fetchOrders({bool reset = false}) async {
    try {
      if (reset) {
        isLoading(true);
        error('');
        orders.clear();
        _nextUrl = null;
      }

      final response = await _dio.get(
        '/api/driver/orders/',
        queryParameters: _buildParams(),
      );

      final data = response.data as Map<String, dynamic>;
      _nextUrl = data['next'] as String?;

      final results = (data['results'] as List<dynamic>? ?? [])
          .map((e) => OrdersModel.fromJson(e as Map<String, dynamic>))
          .toList();

      orders.assignAll(results);
    } catch (e) {
      error(e.toString());
    } finally {
      isLoading(false);
    }
  }

  // ── Load more (pagination) ────────────────────────────────────────────────
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

  // ── Search ────────────────────────────────────────────────────────────────
  void onSearchChanged(String value) {
    searchQuery.value = value;
    fetchOrders(reset: true);
  }

  // ── Filter by status ──────────────────────────────────────────────────────
  void onStatusSelected(String status) {
    selectedStatus.value = status == 'all' ? '' : status;
    fetchOrders(reset: true);
  }

  // ── Fetch detail ──────────────────────────────────────────────────────────
  Future<void> fetchOrderDetail(int id) async {
    try {
      isDetailLoading(true);
      detailError('');
      orderDetail.value = null;

      final response = await _dio.get('/api/driver/order/$id/');
      orderDetail.value = OrdersModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      detailError(e.toString());
    } finally {
      isDetailLoading(false);
    }
  }
}