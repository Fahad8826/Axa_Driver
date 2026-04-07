import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_error_handler.dart';

class AppFeedback {
  AppFeedback._();

  static void success(String message) {
    _show(
      label: 'SUCCESS',
      message: message,
      accentColor: const Color(0xFF22C55E),
      icon: Icons.check_rounded,
    );
  }

  static void error(String message) {
    _show(
      label: 'ERROR',
      message: message,
      accentColor: const Color(0xFFEF4444),
      icon: Icons.error_outline_rounded,
    );
  }

  static void warning(String message) {
    _show(
      label: 'WARNING',
      message: message,
      accentColor: const Color(0xFFF59E0B),
      icon: Icons.warning_amber_rounded,
    );
  }

  static void fromError(AppError error) {
    _show(
      label: 'ERROR',
      message: error.message,
      accentColor: const Color(0xFFEF4444),
      icon: Icons.error_outline_rounded,
    );
  }

  static void _show({
    required String label,
    required String message,
    required Color accentColor,
    required IconData icon,
  }) {
    // Dismiss any existing snackbar cleanly before showing a new one
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.rawSnackbar(
      messageText: _Toast(
        label: label,
        message: message,
        accentColor: accentColor,
        icon: icon,
      ),
      backgroundColor: Colors.transparent,
      boxShadows: const [],
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      borderRadius: 0,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 300),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Toast extends StatelessWidget {
  final String label;
  final String message;
  final Color accentColor;
  final IconData icon;

  const _Toast({
    required this.label,
    required this.message,
    required this.accentColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: accentColor, width: 3),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          // Icon badge
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accentColor, size: 17),
          ),
          const SizedBox(width: 12),

          // Label + message
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                    letterSpacing: 0.6,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.85),
                    height: 1.45,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Dismiss
          GestureDetector(
            onTap: () => Get.closeCurrentSnackbar(),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close_rounded,
                size: 15,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}