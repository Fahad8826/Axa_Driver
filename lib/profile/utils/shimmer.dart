import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════════════════════
//  PROFILE SHIMMER SKELETON
// ════════════════════════════════════════════════════════════════════════════

class ProfileShimmer extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;

  const ProfileShimmer({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  State<ProfileShimmer> createState() => _ProfileShimmerState();
}

class _ProfileShimmerState extends State<ProfileShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    double radius = 8,
    bool isCircle = false,
  }) =>
      AnimatedBuilder(
        animation: _animation,
        builder: (_, __) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isCircle ? null : BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFEEEEEE),
                Color(0xFFF5F5F5),
                Color(0xFFEEEEEE),
              ],
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                (_animation.value).clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
            ),
          ),
        ),
      );

  Widget _shimmerCard({required Widget child}) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimens.cardRadius),
          boxShadow: AppShadows.card,
        ),
        padding: AppDimens.cardPadding,
        child: child,
      );

  Widget _shimmerRow(double w, double h) => Padding(
        padding: EdgeInsets.symmetric(vertical: h * 0.011),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _shimmerBox(width: w * 0.28, height: 13),
            _shimmerBox(width: w * 0.30, height: 13),
          ],
        ),
      );

  Widget _shimmerSettingsRow(double w, double h, double labelWidth) => Padding(
        padding: EdgeInsets.symmetric(vertical: h * 0.012),
        child: Row(
          children: [
            _shimmerBox(
              width: AppDimens.iconMd,
              height: AppDimens.iconMd,
              radius: 4,
            ),
            const SizedBox(width: 12),
            _shimmerBox(width: labelWidth, height: 14, radius: 5),
            const Spacer(),
            _shimmerBox(width: 16, height: 16, radius: 4),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final w = widget.screenWidth;
    final h = widget.screenHeight;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: w * 0.05,
        vertical: h * 0.022,
      ),
      child: Column(
        children: [
          // ── Avatar shimmer card ─────────────────────────────────────────
          _shimmerCard(
            child: Column(
              children: [
                SizedBox(height: h * 0.012),
                Center(
                  child: _shimmerBox(
                    width: w * 0.26,
                    height: w * 0.26,
                    isCircle: true,
                  ),
                ),
                SizedBox(height: h * 0.016),
                Center(
                  child: _shimmerBox(width: w * 0.40, height: 18, radius: 6),
                ),
                SizedBox(height: h * 0.010),
                Center(
                  child: _shimmerBox(width: w * 0.55, height: 13, radius: 5),
                ),
                SizedBox(height: h * 0.006),
                Center(
                  child: _shimmerBox(width: w * 0.38, height: 13, radius: 5),
                ),
                SizedBox(height: h * 0.012),
              ],
            ),
          ),

          SizedBox(height: h * 0.018),

          // ── Vehicle details shimmer card ────────────────────────────────
          _shimmerCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _shimmerBox(
                      width: AppDimens.iconMd,
                      height: AppDimens.iconMd,
                      radius: 4,
                    ),
                    const SizedBox(width: 8),
                    _shimmerBox(width: w * 0.30, height: 15, radius: 5),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(color: AppColors.divider, thickness: 1, height: 1),
                _shimmerRow(w, h),
                _shimmerRow(w, h),
                _shimmerRow(w, h),
              ],
            ),
          ),

          SizedBox(height: h * 0.018),

          // ── Bank details shimmer card ───────────────────────────────────
          _shimmerCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _shimmerBox(
                      width: AppDimens.iconMd,
                      height: AppDimens.iconMd,
                      radius: 4,
                    ),
                    const SizedBox(width: 8),
                    _shimmerBox(width: w * 0.28, height: 15, radius: 5),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(color: AppColors.divider, thickness: 1, height: 1),
                _shimmerRow(w, h),
                _shimmerRow(w, h),
                _shimmerRow(w, h),
                _shimmerRow(w, h),
              ],
            ),
          ),

          SizedBox(height: h * 0.018),

          // ── Settings shimmer card ───────────────────────────────────────
          _shimmerCard(
            child: Column(
              children: [
                _shimmerSettingsRow(w, h, w * 0.38),
                const Divider(color: AppColors.divider, thickness: 1, height: 1),
                _shimmerSettingsRow(w, h, w * 0.32),
                const Divider(color: AppColors.divider, thickness: 1, height: 1),
                _shimmerSettingsRow(w, h, w * 0.20),
              ],
            ),
          ),

          SizedBox(height: h * 0.03),
        ],
      ),
    );
  }
}