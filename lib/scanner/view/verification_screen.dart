import 'package:axa_driver/core/services/routers.dart';
import 'package:axa_driver/core/theme/app_icons.dart';
import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class DeliveryVerifiedView extends StatefulWidget {
  const DeliveryVerifiedView({super.key});

  @override
  State<DeliveryVerifiedView> createState() => _DeliveryVerifiedViewState();
}

class _DeliveryVerifiedViewState extends State<DeliveryVerifiedView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // ── Read args passed from ScannerController ────────────────────────────────
  late final bool _isSuccess;
  late final String _message;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>?;
    _isSuccess = args?['success'] as bool? ?? false;

    // Simplify error messages
    if (!_isSuccess) {
      _message = 'Invalid QR code';
    } else {
      _message = args?['message'] as String? ??
          'Delivery confirmed successfully!';
    }

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _scaleAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.0, 0.65, curve: Curves.elasticOut),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.35, 1.0, curve: Curves.easeIn),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animCtrl.forward();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Illustration ─────────────────────────────────────────────
              ScaleTransition(
                scale: _scaleAnim,
                child: _isSuccess
                    ? SvgPicture.asset(
                        AppIcons.success,
                        width: 240,
                        height: 240,
                      )
                    : Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.statusCancelledSurface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 56,
                          color: AppColors.statusCancelled,
                        ),
                      ),
              ),

              const Spacer(),

              // ── Text block ───────────────────────────────────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    children: [
                      Text(
                        _isSuccess
                            ? 'Delivery Completed\nSuccessfully !!'
                            : 'Verification Failed',
                        style: AppTextStyles.headingLarge.copyWith(
                          fontSize: 22,
                          height: 1.35,
                          color: _isSuccess
                              ? AppColors.textPrimary
                              : AppColors.statusCancelled,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),

                      // ── API response message ──────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: _isSuccess
                              ? AppColors.statusDeliveredSurface.withOpacity(0.8)
                              : AppColors.statusCancelledSurface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isSuccess
                                ? AppColors.statusDelivered.withOpacity(0.3)
                                : AppColors.statusCancelled.withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_isSuccess ? AppColors.statusDelivered : AppColors.statusCancelled)
                                  .withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isSuccess
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.error_outline_rounded,
                              size: 18,
                              color: _isSuccess
                                  ? AppColors.statusDelivered
                                  : AppColors.statusCancelled,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _message,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: _isSuccess
                                      ? AppColors.statusDelivered
                                      : AppColors.statusCancelled,
                                  height: 1.5,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (_isSuccess) ...[
                        const SizedBox(height: 12),
                        Text(
                          'The order has been delivered\nand marked as complete. Great job!\nKeep up the good work.',
                          style:
                              AppTextStyles.bodyMedium.copyWith(height: 1.6),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // ── Modern Action Buttons ──────────────────────────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Primary Button (Back to Home)
                      Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primary.withOpacity(0.9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => Get.offAllNamed(AppRoutes.navbar),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Back to Home',
                            style: AppTextStyles.button.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),

                      // Secondary Button (Try Again - only on failure)
                      if (!_isSuccess) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () {
                              Get.offNamed(AppRoutes.scanner, arguments: {'retry': true});
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(
                                color: AppColors.primary.withOpacity(0.8),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: AppColors.primary.withOpacity(0.05),
                            ),
                            child: Text(
                              'Try Again',
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}