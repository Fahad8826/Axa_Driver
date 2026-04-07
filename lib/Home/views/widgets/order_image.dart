// Order image — network image with fallback placeholder.
import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:flutter/material.dart';

class OrderImage extends StatelessWidget {
  const OrderImage({super.key, required this.size, this.imageUrl});

  final double size;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.cardRadiusSmall),
      child: SizedBox(
        width: size,
        height: size,
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: AppColors.primarySurface,
    child: Icon(
      Icons.water_drop_rounded,
      color: AppColors.primary,
      size: size * 0.45,
    ),
  );
}