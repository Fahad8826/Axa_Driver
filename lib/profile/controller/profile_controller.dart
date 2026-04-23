import 'package:axa_driver/core/network/dioclient.dart';
import 'package:axa_driver/core/services/app_pref.dart';
import 'package:axa_driver/core/services/routers.dart';
import 'package:axa_driver/core/theme/utils/app_error_handler.dart';
import 'package:axa_driver/core/theme/utils/snackbars.dart';
import 'package:axa_driver/profile/model/profile_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final Dio _dio = DioClient.dio;
  final ImagePicker _picker = ImagePicker();

  // ── State ─────────────────────────────────────────────────────────────────
  final Rx<ProfileModel?> profile  = Rx<ProfileModel?>(null);
  final RxBool isLoading           = true.obs;
  final RxBool isLoggingOut        = false.obs;
  final RxBool isUpdating          = false.obs;
  final RxBool isChangingPassword  = false.obs;
  final RxBool isDeletingAccount   = false.obs;
  final RxBool isUploadingPhoto    = false.obs;
  final RxString error             = ''.obs;

  // ── Edit profile controllers ───────────────────────────────────────────────
  late final TextEditingController nameCtrl;
  late final TextEditingController emailCtrl;
  late final TextEditingController vehicleNumberCtrl;
  late final TextEditingController vehicleModelCtrl;
  late final TextEditingController vehicleOwnerCtrl;
  late final TextEditingController accountNumberCtrl;
  late final TextEditingController bankNameCtrl;
  late final TextEditingController branchNameCtrl;
  late final TextEditingController ifscCodeCtrl;

  // ── Change password controllers ────────────────────────────────────────────
  late final TextEditingController oldPasswordCtrl;
  late final TextEditingController newPasswordCtrl;
  late final TextEditingController confirmPasswordCtrl;

  final RxBool showOldPassword     = false.obs;
  final RxBool showNewPassword     = false.obs;
  final RxBool showConfirmPassword = false.obs;

  @override
  void onInit() {
    super.onInit();
    nameCtrl            = TextEditingController();
    emailCtrl           = TextEditingController();
    vehicleNumberCtrl   = TextEditingController();
    vehicleModelCtrl    = TextEditingController();
    vehicleOwnerCtrl    = TextEditingController();
    accountNumberCtrl   = TextEditingController();
    bankNameCtrl        = TextEditingController();
    branchNameCtrl      = TextEditingController();
    ifscCodeCtrl        = TextEditingController();
    oldPasswordCtrl     = TextEditingController();
    newPasswordCtrl     = TextEditingController();
    confirmPasswordCtrl = TextEditingController();
    fetchProfile();
  }

  // ── Fetch profile ──────────────────────────────────────────────────────────
  Future<void> fetchProfile() async {
    try {
      isLoading(true);
      error('');
      final response = await _dio.get('/api/driver/profile/');
      if (response.statusCode == 200) {
        profile.value = ProfileModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
    } on DioException catch (e) {
      final appError = AppErrorHandler.fromDioException(e);
      error(appError.message);
      AppFeedback.fromError(appError);
    } catch (_) {
      final appError = AppErrorHandler.generic();
      error(appError.message);
      AppFeedback.fromError(appError);
    } finally {
      isLoading(false);
    }
  }

  // ── Prepare edit controllers ───────────────────────────────────────────────
  void prepareEditControllers() {
    final p = profile.value;
    if (p == null) return;
    nameCtrl.text          = p.name;
    emailCtrl.text         = p.email;
    vehicleNumberCtrl.text = p.vehicleNumber;
    vehicleModelCtrl.text  = p.vehicleModel;
    vehicleOwnerCtrl.text  = p.vehicleOwner;
    accountNumberCtrl.text = p.accountNumber;
    bankNameCtrl.text      = p.bankName;
    branchNameCtrl.text    = p.branchName;
    ifscCodeCtrl.text      = p.ifscCode;
  }

  // ── Update profile ─────────────────────────────────────────────────────────
  Future<void> updateProfile() async {
    try {
      isUpdating(true);
      final response = await _dio.patch(
        '/api/driver/profile/',
        data: {
          'name':           nameCtrl.text.trim(),
          'email':          emailCtrl.text.trim(),
          'vehicle_number': vehicleNumberCtrl.text.trim(),
          'vehicle_model':  vehicleModelCtrl.text.trim(),
          'vehicle_owner':  vehicleOwnerCtrl.text.trim(),
          'account_number': accountNumberCtrl.text.trim(),
          'bank_name':      bankNameCtrl.text.trim(),
          'branch_name':    branchNameCtrl.text.trim(),
          'ifsc_code':      ifscCodeCtrl.text.trim(),
        },
      );
      if (response.statusCode == 200) {
        profile.value = ProfileModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        Get.back();
        AppFeedback.success('Profile updated successfully.');
      }
    } on DioException catch (e) {
      AppFeedback.fromError(AppErrorHandler.fromDioException(e));
    } catch (_) {
      AppFeedback.fromError(AppErrorHandler.generic());
    } finally {
      isUpdating(false);
    }
  }

  // ── Pick & upload profile picture ──────────────────────────────────────────
  Future<void> pickAndUploadProfilePicture({required bool fromCamera}) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked == null) return;

      isUploadingPhoto(true);

      final formData = FormData.fromMap({
        'profile_picture': await MultipartFile.fromFile(
          picked.path,
          filename: picked.name,
        ),
      });

      final response = await _dio.patch(
        '/api/driver/profile/',
        data: formData,
      );

      if (response.statusCode == 200) {
        profile.value = ProfileModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        AppFeedback.success('Profile photo updated.');
      }
    } on DioException catch (e) {
      AppFeedback.fromError(AppErrorHandler.fromDioException(e));
    } catch (_) {
      AppFeedback.fromError(AppErrorHandler.generic());
    } finally {
      isUploadingPhoto(false);
    }
  }

  // ── Prepare password controllers ───────────────────────────────────────────
  void preparePasswordControllers() {
    oldPasswordCtrl.clear();
    newPasswordCtrl.clear();
    confirmPasswordCtrl.clear();
    showOldPassword(false);
    showNewPassword(false);
    showConfirmPassword(false);
  }

  // ── Change password ────────────────────────────────────────────────────────
  Future<void> changePassword() async {
    final oldPw     = oldPasswordCtrl.text.trim();
    final newPw     = newPasswordCtrl.text.trim();
    final confirmPw = confirmPasswordCtrl.text.trim();

    if (oldPw.isEmpty || newPw.isEmpty || confirmPw.isEmpty) {
      AppFeedback.warning('All password fields are required.');
      return;
    }
    if (newPw.length < 6) {
      AppFeedback.warning('New password must be at least 6 characters.');
      return;
    }
    if (newPw != confirmPw) {
      AppFeedback.warning('Passwords do not match.');
      return;
    }

    try {
      isChangingPassword(true);
      final response = await _dio.post(
        '/api/driver/change-password/',
        data: {
          'old_password':     oldPw,
          'new_password':     newPw,
          'confirm_password': confirmPw,
        },
      );
      if (response.statusCode == 200) {
        Get.back();
        AppFeedback.success(
          response.data['message'] ?? 'Password changed successfully.',
        );
      }
    } on DioException catch (e) {
      AppFeedback.fromError(AppErrorHandler.fromDioException(e));
    } catch (_) {
      AppFeedback.fromError(AppErrorHandler.generic());
    } finally {
      isChangingPassword(false);
    }
  }

  // ── Delete account ─────────────────────────────────────────────────────────
  // Future<void> deleteAccount() async {
  //   try {
  //     isDeletingAccount(true);
  //     await _dio.delete('/api/driver/delete-account/');
  //     await AppPrefs.clear();
  //     Get.offAllNamed(AppRoutes.login);
  //   } on DioException catch (e) {
  //     AppFeedback.fromError(AppErrorHandler.fromDioException(e));
  //   } catch (_) {
  //     AppFeedback.fromError(AppErrorHandler.generic());
  //   } finally {
  //     isDeletingAccount(false);
  //   }
  // }
Future<void> deleteAccount() async {
  try {
    isDeletingAccount(true);

    await _dio.delete('/api/driver/delete-account/');

    await AppPrefs.clear();
    await AppPrefs.setLoggedIn(false);

    Get.offAllNamed(AppRoutes.login);

  } catch (e) {
    print(e);
    AppFeedback.fromError(AppErrorHandler.generic());
  } finally {
    isDeletingAccount(false);
  }
}
  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      isLoggingOut(true);
      final refreshToken = await AppPrefs.getRefreshToken();
      await _dio.post(
        '/api/driver/logout/',
        data: {'refresh': refreshToken},
      );
    } on DioException catch (_) {
      // Silent fail — always log out locally
    } catch (_) {
      // Same
    } finally {
      isLoggingOut(false);
      await AppPrefs.clear();
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    vehicleNumberCtrl.dispose();
    vehicleModelCtrl.dispose();
    vehicleOwnerCtrl.dispose();
    accountNumberCtrl.dispose();
    bankNameCtrl.dispose();
    branchNameCtrl.dispose();
    ifscCodeCtrl.dispose();
    oldPasswordCtrl.dispose();
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.onClose();
  }
}