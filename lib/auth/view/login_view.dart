import 'package:axa_driver/auth/controller/auth_controller.dart';
import 'package:axa_driver/core/theme/apptheme.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth  = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,           // ← shrinks body when keyboard appears
      body: SafeArea(
        child: SingleChildScrollView(           // ← only change: scroll when keyboard pushes content
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          child: SizedBox(
            width: screenWidth,
            height: screenHeight,               // ← kept exactly as original
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Top spacer (~30% down) ─────────────────────────────
                    SizedBox(height: screenHeight * 0.28),

                    // ── Title ──────────────────────────────────────────────
                    Text(
                      'Login to your account',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headingLarge.copyWith(
                        fontSize: screenHeight * 0.028,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.010),

                    // ── Subtitle ───────────────────────────────────────────
                    Text(
                      'Securely login with phone number',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: screenHeight * 0.018,
                        color: AppColors.textHint,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.040),

                    // ── Phone field ────────────────────────────────────────
                    TextFormField(
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      validator: controller.validatePhone,
                      style: AppTextStyles.inputText,
                      decoration: InputDecoration(
                        hintText: '+91 9585258745',
                        hintStyle: AppTextStyles.inputHint,
                        filled: true,
                        fillColor: AppColors.inputFill,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14),
                          child: Icon(
                            Icons.phone_outlined,
                            color: AppColors.primary,
                            size: AppDimens.iconMd,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimens.inputRadius),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimens.inputRadius),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimens.inputRadius),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.8),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimens.inputRadius),
                          borderSide: const BorderSide(
                              color: AppColors.statusCancelled,
                              width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.018),

                    // ── Password field ─────────────────────────────────────
                    Obx(
                      () => TextFormField(
                        controller: controller.passwordController,
                        obscureText:
                            !controller.isPasswordVisible.value,
                        validator: controller.validatePassword,
                        style: AppTextStyles.inputText,
                        decoration: InputDecoration(
                          hintText: '••••••••••',
                          hintStyle: AppTextStyles.inputHint,
                          filled: true,
                          fillColor: AppColors.inputFill,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14),
                            child: Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.primary,
                              size: AppDimens.iconMd,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordVisible.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textHint,
                              size: AppDimens.iconMd,
                            ),
                            onPressed: controller.togglePassword,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimens.inputRadius),
                            borderSide: const BorderSide(
                                color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimens.inputRadius),
                            borderSide: const BorderSide(
                                color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimens.inputRadius),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 1.8),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimens.inputRadius),
                            borderSide: const BorderSide(
                                color: AppColors.statusCancelled,
                                width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.026),

                    // ── Continue button ────────────────────────────────────
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: screenHeight * 0.063,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
                            disabledBackgroundColor:
                                AppColors.primary.withOpacity(0.6),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimens.buttonRadius),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.white,
                                  ),
                                )
                              : Text(
                                  'Continue',
                                  style: AppTextStyles.button.copyWith(
                                    fontSize: screenHeight * 0.022,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.022),

                    // ── Forgot password row ────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Forgot Password? ',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: screenHeight * 0.017,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.contactAdmin,
                          child: Text(
                            'Contact Admin',
                            style: AppTextStyles.labelMedium.copyWith(
                              fontSize: screenHeight * 0.017,
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // ── Terms & Privacy ────────────────────────────────────
                    Padding(
                      padding:
                          EdgeInsets.only(bottom: screenHeight * 0.024),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: AppTextStyles.caption.copyWith(
                            fontSize: screenHeight * 0.015,
                            color: AppColors.textHint,
                          ),
                          children: [
                            const TextSpan(
                              text:
                                  'By clicking Continue, you agree to our ',
                            ),
                            TextSpan(
                              text: 'Terms of Service',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: screenHeight * 0.015,
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primary,
                              ),
                            ),
                            const TextSpan(text: '\nand '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: screenHeight * 0.015,
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}