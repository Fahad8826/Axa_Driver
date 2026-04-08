import 'package:axa_driver/core/network/dioclient.dart';
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

  bool _hasScanned = false; // guard against double-scan

  // ── Called by the scanner widget on every detected barcode ────────────────
  void onDetect(BarcodeCapture capture) {
    if (_hasScanned || isProcessing.value) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final rawValue = barcode.rawValue!;
    debugPrint('QR raw value: $rawValue');

    // ── Extract token from URL ─────────────────────────────────────────────
    // Supports:
    //   https://example.com/deliver?token=eff28e44-...
    //   https://example.com/deliver/eff28e44-.../
    //   plain UUID fallback
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

  // ── Token extraction logic ─────────────────────────────────────────────────
  String? _extractToken(String rawValue) {
    try {
      final uri = Uri.tryParse(rawValue);

      if (uri != null) {
        // 1. Try query param: ?token=xxx or ?qr_token=xxx
        if (uri.queryParameters.containsKey('token')) {
          return uri.queryParameters['token'];
        }
        if (uri.queryParameters.containsKey('qr_token')) {
          return uri.queryParameters['qr_token'];
        }

        // 2. Try last path segment if it looks like a UUID
        final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
        if (segments.isNotEmpty) {
          final last = segments.last;
          if (_isUuid(last)) return last;
        }
      }

      // 3. Fallback: raw value itself is a UUID
      if (_isUuid(rawValue.trim())) return rawValue.trim();

      return null;
    } catch (e) {
      debugPrint('Token extraction error: $e');
      return null;
    }
  }

  bool _isUuid(String value) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(value);
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
        Get.back(result: {'success': true, 'data': response.data});
      } else {
        _onError('Unexpected response: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['detail'] ??
          e.response?.data?['message'] ??
          e.message ??
          'Scan failed. Please try again.';
      _onError(msg.toString());
    } catch (e) {
      _onError('Something went wrong. Please try again.');
    } finally {
      isProcessing(false);
    }
  }

  // ── Reset scanner to try again after error ─────────────────────────────────
  void retryScanner() {
    _hasScanned = false;
    error('');
    cameraController.start();
  }

  void _onError(String msg) {
    error(msg);
    _hasScanned = false; // allow retry
    cameraController.start();
  }

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }
}