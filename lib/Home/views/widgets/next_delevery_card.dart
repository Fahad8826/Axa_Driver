import 'package:axa_driver/Home/model/home_model.dart';
import 'package:axa_driver/Home/views/home_view.dart';
import 'package:axa_driver/Home/views/widgets/order_image.dart';
import 'package:axa_driver/core/services/app_layout.dart';
import 'package:axa_driver/core/theme/app_icons.dart';
import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:axa_driver/core/services/routers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NextDeliveryCard extends StatelessWidget {
  const NextDeliveryCard({super.key, required this.order, required this.layout});

  final OrderModel order;
  final AppLayout layout;

  @override
  Widget build(BuildContext context) {
    final imgSize = layout.productImageSm;
    final rowGap = layout.innerGapSm;
    final String? imageUrl = firstImageUrl(order);

    return Container(
      padding: EdgeInsets.all(layout.hPad * 0.7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product image
          OrderImage(size: imgSize, imageUrl: imageUrl),

          SizedBox(width: layout.hPad * 0.5),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer name
                InfoRow(
                  icon: AppIcons.profile,
                  text: order.customerName,
                  isTitle: true,
                  iconSize: layout.iconSm,
                ),
                SizedBox(height: rowGap),

                // Address
                InfoRow(
                  icon: AppIcons.map,
                  text: order.address,
                  iconSize: layout.iconSm,
                ),
                SizedBox(height: rowGap),

                // Water cans summary (compact — only cans for list card)
                if (order.waterCans.isNotEmpty)
                  InfoRow(
                    icon: AppIcons.bag,
                    text: order.waterCanSummary,
                    iconSize: layout.iconSm,
                  ),

                SizedBox(height: layout.innerGapMd),

                SizedBox(
                  width: double.infinity,
                  height: layout.buttonHeightSm,
                  child: ElevatedButton(
                    onPressed: () {
                      debugPrint('Navigating with lat: ${order.latitude}, lng: ${order.longitude}');
                      debugPrint('Parsed lat: ${double.tryParse(order.latitude)}, lng: ${double.tryParse(order.longitude)}');

                      Get.toNamed(
                        AppRoutes.navigation,
                        arguments: {
                          'orderId': order.id,
                          'destLat': double.tryParse(order.latitude) ?? 0.0,
                          'destLng': double.tryParse(order.longitude) ?? 0.0,
                        },
                      );
                    },
                    child: Text(
                      'Start Navigation',
                      style: AppTextStyles.buttonSmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
