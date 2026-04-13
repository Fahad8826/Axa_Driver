import 'package:axa_driver/core/network/dioclient.dart';
import 'package:axa_driver/core/services/routers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerController extends GetxController {
  final Dio _dio = DioClient.dio;

  // ── State ──────────────────────────────────────────────────────────────────
  final isProcessing = false.obs;
  final error = ''.obs;

  // ── Mobile Scanner camera controller ──────────────────────────────────────
  final cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  bool _hasScanned = false;

  @override
  void onInit() {
    super.onInit();
    // Check if we should retry scanning
    final args = Get.arguments as Map<String, dynamic>?;
    if (args?['retry'] == true) {
      retryScanner();
    }
  }

  // ── Called by the scanner widget on every detected barcode ────────────────
  void onDetect(BarcodeCapture capture) {
    if (_hasScanned || isProcessing.value) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final rawValue = barcode.rawValue!;
    debugPrint('QR raw value: $rawValue');

    final token = _extractToken(rawValue);
    if (token == null || token.isEmpty) {
      error('Invalid QR code. Could not extract token.');
      return;
    }

    debugPrint('Extracted token: $token');
    _hasScanned = true;
    cameraController.stop();
    _submitToken(token);
  }

  // ── POST token to backend ──────────────────────────────────────────────────
  Future<void> _submitToken(String token) async {
    try {
      isProcessing(true);
      error('');

      final response = await _dio.post(
        '/api/driver/scan-deliver/',
        data: {'qr_token': token},
      );

      if (response.statusCode == 200) {
        debugPrint('Scan success: ${response.data}');
        Get.offNamed(AppRoutes.deliveryVerified, arguments: {
          'success': true,
          'message': response.data?['message'] ??
              response.data?['detail'] ??
              'Delivery confirmed successfully!',
        });
      } else {
        _navigateToVerified(
          success: false,
          message: 'Unexpected response: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['detail'] ??
          e.response?.data?['message'] ??
          e.message ??
          'Scan failed. Please try again.';
      _navigateToVerified(success: false, message: msg.toString());
    } catch (e) {
      _navigateToVerified(
          success: false, message: 'Something went wrong. Please try again.');
    } finally {
      isProcessing(false);
    }
  }

  void _navigateToVerified(
      {required bool success, required String message}) {
    Get.offNamed(AppRoutes.deliveryVerified, arguments: {
      'success': success,
      'message': message,
    });
  }

  // ── Token extraction ───────────────────────────────────────────────────────
  String? _extractToken(String rawValue) {
    try {
      final uri = Uri.tryParse(rawValue);
      if (uri != null) {
        if (uri.queryParameters.containsKey('token')) {
          return uri.queryParameters['token'];
        }
        if (uri.queryParameters.containsKey('qr_token')) {
          return uri.queryParameters['qr_token'];
        }
        final segments =
            uri.pathSegments.where((s) => s.isNotEmpty).toList();
        if (segments.isNotEmpty && _isUuid(segments.last)) {
          return segments.last;
        }
      }
      if (_isUuid(rawValue.trim())) return rawValue.trim();
      return null;
    } catch (e) {
      debugPrint('Token extraction error: $e');
      return null;
    }
  }

  bool _isUuid(String value) {
    return RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    ).hasMatch(value);
  }

  // ── Retry ──────────────────────────────────────────────────────────────────
  void retryScanner() {
    _hasScanned = false;
    error('');
    cameraController.start();
  }

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }
}