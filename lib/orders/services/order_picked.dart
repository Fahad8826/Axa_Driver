import 'package:axa_driver/core/network/dioclient.dart';
import 'package:axa_driver/core/theme/utils/snackbars.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class OrderService {
  static final Dio _dio = DioClient.dio;

  /// Mark order as picked. Returns true on success.
  /// Shows snackbar on both success and failure.
  static Future<bool> markAsPicked(int orderId) async {
    try {
      final response = await _dio.patch(
        '/api/driver/orders/$orderId/mark-picked/',
      );
      if (response.statusCode == 200) {
        AppFeedback.success('Order marked as picked!');
        return true;
      } else {
        AppFeedback.error('Failed to update order status.');
        return false;
      }
    } on DioException catch (e) {
      AppFeedback.error(
        e.response?.data?['message'] ?? e.message ?? 'Something went wrong.',
      );
      return false;
    } catch (e) {
      debugPrint('[OrderService] markAsPicked error: $e');
      AppFeedback.error('Something went wrong.');
      return false;
    }
  }
}