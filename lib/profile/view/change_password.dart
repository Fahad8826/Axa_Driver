import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:axa_driver/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    final mq = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text('Change Password', style: AppTextStyles.headingMedium),
        actions: [
          Obx(
            () => TextButton(
              onPressed: controller.isChangingPassword.value
                  ? null
                  : controller.changePassword,
              child: controller.isChangingPassword.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Text(
                      'Save',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          24,
          32,
          24,
          mq.viewInsets.bottom + 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info banner ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Use at least 6 characters. You will be asked to log in again after changing.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Fields ─────────────────────────────────────────────────────
            Obx(
              () => _PasswordField(
                label: 'Current Password',
                ctrl: controller.oldPasswordCtrl,
                isVisible: controller.showOldPassword.value,
                onToggle: controller.showOldPassword.toggle,
              ),
            ),
            Obx(
              () => _PasswordField(
                label: 'New Password',
                ctrl: controller.newPasswordCtrl,
                isVisible: controller.showNewPassword.value,
                onToggle: controller.showNewPassword.toggle,
              ),
            ),
            Obx(
              () => _PasswordField(
                label: 'Confirm New Password',
                ctrl: controller.confirmPasswordCtrl,
                isVisible: controller.showConfirmPassword.value,
                onToggle: controller.showConfirmPassword.toggle,
              ),
            ),

            const SizedBox(height: 32),

            // ── Submit ─────────────────────────────────────────────────────
            // Obx(
            //   () => SizedBox(
            //     width: double.infinity,
            //     height: AppDimens.buttonHeight,
            //     child: ElevatedButton(
            //       onPressed: controller.isChangingPassword.value
            //           ? null
            //           : controller.changePassword,
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: AppColors.primary,
            //         disabledBackgroundColor:
            //             AppColors.primary.withOpacity(0.6),
            //         elevation: 0,
            //         shape: RoundedRectangleBorder(
            //           borderRadius:
            //               BorderRadius.circular(AppDimens.buttonRadius),
            //         ),
            //       ),
            //       child: controller.isChangingPassword.value
            //           ? const SizedBox(
            //               width: 22,
            //               height: 22,
            //               child: CircularProgressIndicator(
            //                   color: Colors.white, strokeWidth: 2.5),
            //             )
            //           : Text('Update Password', style: AppTextStyles.button),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final bool isVisible;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.label,
    required this.ctrl,
    required this.isVisible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextField(
          controller: ctrl,
          obscureText: !isVisible,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.lock_outline_rounded,
                size: 18, color: AppColors.textSecondary),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: onToggle,
            ),
            labelStyle: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      );
}