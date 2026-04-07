import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:flutter/material.dart';


class ErrorView extends StatelessWidget {
  const ErrorView({required this.message, required this.onRetry});
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
                size: 48, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text('Something went wrong',
                style: AppTextStyles.headingSmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            // Text(message,
            //     style: AppTextStyles.bodyMedium,
            //     textAlign: TextAlign.center,
            //     maxLines: 3,
            //     overflow: TextOverflow.ellipsis),
            const SizedBox(height: 20),
            SizedBox(
              width: 160,
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