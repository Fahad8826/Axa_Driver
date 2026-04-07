import 'package:axa_driver/Home/model/home_model.dart';
import 'package:axa_driver/Home/views/home_view.dart';
import 'package:axa_driver/Home/views/widgets/order_image.dart';
import 'package:axa_driver/core/services/app_layout.dart';
import 'package:axa_driver/core/theme/app_icons.dart';
import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:axa_driver/core/services/routers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class CurrentDeliveryCard extends StatelessWidget {
  const CurrentDeliveryCard({required this.order, required this.layout});

  final OrderModel order;
  final AppLayout layout;

  @override
  Widget build(BuildContext context) {
    final imgSize = layout.productImageLg;
    final rowGap = layout.innerGapSm;

    // All item lines: water cans → products → addons
    final List<String> itemLines = [
      ...order.waterCans.map((c) => '${c.quantity} × ${c.name}'),
      ...order.products.map((p) => '${p.quantity} × ${p.name}'),
      ...order.addons.map((a) => '${a.quantity} × ${a.name}'),
    ];

    final String? imageUrl = firstImageUrl(order);

    return Container(
      padding: EdgeInsets.all(layout.hPad * 0.7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image — rounded rectangle, real image or placeholder
              OrderImage(size: imgSize, imageUrl: imageUrl),

              SizedBox(width: layout.hPad * 0.5),

              // Order details
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

                    // Each item on its own row (matches Figma)
                    ...itemLines.map(
                      (line) => Padding(
                        padding: EdgeInsets.only(top: rowGap),
                        child: InfoRow(
                          icon: AppIcons.bag,
                          text: line,
                          iconSize: layout.iconSm,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: layout.innerGapMd),
          const Divider(height: 1, color: AppColors.divider),
          SizedBox(height: layout.innerGapMd),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: layout.buttonHeightSm,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.toNamed(
                        AppRoutes.navigation,
                        arguments: {
                          'orderId': order.id,
                          'destLat': double.tryParse(order.latitude) ?? 0.0,
                          'destLng': double.tryParse(order.longitude) ?? 0.0,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            AppIcons.map,
                            width: layout.iconSm,
                            height: layout.iconSm,
                            colorFilter: const ColorFilter.mode(
                              AppColors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Start Navigation',
                            style: AppTextStyles.buttonSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: layout.hPad * 0.4),
              Expanded(
                child: SizedBox(
                  height: layout.buttonHeightSm,
                  child: OutlinedButton(
                    onPressed: () async {
                      final url = Uri.parse('tel:${order.phoneNumber}');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            AppIcons.phone,
                            width: layout.iconSm,
                            height: layout.iconSm,
                            colorFilter: const ColorFilter.mode(
                              AppColors.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Call Customer',
                            style: AppTextStyles.buttonSmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
