import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:flutter/material.dart';

class MapFab extends StatelessWidget {
  const MapFab({
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.textPrimary,
  });
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: AppShadows.card,
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }
}