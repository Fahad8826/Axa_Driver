import 'package:axa_driver/core/network/dioclient.dart';
import 'package:axa_driver/core/services/app_pref.dart';
import 'package:axa_driver/core/services/location_service.dart';
import 'package:axa_driver/core/services/routers.dart';
import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:axa_driver/auth/model/auth_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthController extends GetxController {
  final Dio _dio = DioClient.dio;

  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  // ── ADMIN CONTACT ─────────────────────────────────────────────────────────
  static const String _adminWhatsApp = '919999999999'; // TODO: replace

  Future<void> contactAdmin() async {
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$_adminWhatsApp'
      '?text=Hi%2C%20I%20need%20help%20with%20my%20driver%20app%20password.',
    );
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      _showError(
        'Could not open WhatsApp. Please contact your admin directly.',
      );
    }
  }

  // ── LOGIN ─────────────────────────────────────────────────────────────────
  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading(true);

      final response = await _dio.post(
        '/api/driver/login/',
        data: {
          'phone_number': phoneController.text.trim(),
          'password': passwordController.text.trim(),
        },
      );

      final result = LoginResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

           await AppPrefs.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await AppPrefs.setLoggedIn(true);
      print('✅ Access Token: ${result.accessToken}');
      print('✅ Refresh Token: ${result.refreshToken}');
      _showSuccess(
        result.message.isNotEmpty ? result.message : 'Login successful.',
      );
      await startLocationService();

      Get.offAllNamed(AppRoutes.navbar);
    } on DioException catch (e) {
      String errorMessage = 'Login failed. Please try again.';
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response!.data as Map;
        if (data.containsKey('non_field_errors') &&
            data['non_field_errors'] is List &&
            data['non_field_errors'].isNotEmpty) {
          errorMessage = data['non_field_errors'][0].toString();
        } else if (data.containsKey('phone_number') &&
            data['phone_number'] is List &&
            data['phone_number'].isNotEmpty) {
          errorMessage = data['phone_number'][0].toString();
        } else if (data.containsKey('password') &&
            data['password'] is List &&
            data['password'].isNotEmpty) {
          errorMessage = data['password'][0].toString();
        } else if (data.containsKey('message')) {
          errorMessage = data['message'].toString();
        } else if (data.containsKey('detail')) {
          errorMessage = data['detail'].toString();
        }
      }
      _showError(errorMessage);
    } catch (e) {
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading(false);
    }
  }

  // ── LOGOUT ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await AppPrefs.clear();
    Get.offAllNamed(AppRoutes.login);
  }

  // ── VALIDATION ────────────────────────────────────────────────────────────
  String? validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number is required';
    if (v.trim().length < 10) return 'Enter a valid phone number';
    return null;
  }

  String? validatePassword(String? v) {
    if (v == null || v.trim().isEmpty) return 'Password is required';
    if (v.trim().length < 6) return 'Minimum 6 characters';
    return null;
  }

  void togglePassword() => isPasswordVisible.value = !isPasswordVisible.value;

  // ── SNACKBARS ─────────────────────────────────────────────────────────────
  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.statusDelivered,
      colorText: AppColors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.statusCancelled,
      colorText: AppColors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
