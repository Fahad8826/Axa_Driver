import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:flutter/material.dart';


class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
  child: Padding(
    padding: AppDimens.pagePadding,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.wifi_off_rounded,
            size: 36, color: AppColors.textHint),  // was 48
        const SizedBox(height: 10),                // was 12
        Text('Something went wrong',
            style: AppTextStyles.headingSmall,
            textAlign: TextAlign.center),
        const SizedBox(height: 16),               // was 20
        SizedBox(
          width: 140,                             // was 160
          child: ElevatedButton(
            onPressed: onRetry,
            child: Text('Retry', style: AppTextStyles.button),
          ),
        ),
      ],
    ),
  ),
);
  }
}