import 'package:axa_driver/core/utils/date_utils.dart';
import 'package:axa_driver/core/utils/image_utils.dart';
import 'package:axa_driver/Home/model/home_model.dart';
import 'package:axa_driver/Home/views/home_view.dart';
import 'package:axa_driver/core/theme/utils/app_layout.dart';
import 'package:axa_driver/core/theme/app_icons.dart';
import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:axa_driver/core/services/routers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class CurrentDeliveryCard extends StatelessWidget {
  const CurrentDeliveryCard({
    super.key,
    required this.order,
    required this.layout,
  });

  final OrderModel order;
  final AppLayout layout;

  @override
  Widget build(BuildContext context) {
    final double imgSize = layout.productImageLg;
    const double iconSize = 14.0;

    final List<String> itemLines = [
      ...order.waterCans.map((c) => '${c.quantity} × ${c.name}'),
      ...order.products.map((p) => '${p.quantity} × ${p.name}'),
      ...order.addons.map((a) => '${a.quantity} × ${a.name}'),
    ];

    final String? imageUrl = firstImageUrl(order);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: circle image + info ─────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circle image — matches Figma
              _CircleImage(size: imgSize, imageUrl: imageUrl),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: InfoRow(
                    icon: AppIcons.profile,
                    text: order.customerName.isNotEmpty ? order.customerName : '—',
                    isTitle: true,
                    iconSize: iconSize,
                  ),
                ),
                Text(
                  AppDateUtils.formatShortDate(order.scheduledDate),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
                    const SizedBox(height: 4),
                    InfoRow(
                      icon: AppIcons.map,
                      text: order.address.isNotEmpty ? order.address : '—',
                      iconSize: iconSize,
                    ),
                    if (itemLines.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: InfoRow(
                          icon: AppIcons.bag,
                          text: '0 × items',
                          iconSize: iconSize,
                        ),
                      )
                    else
                      ...itemLines.map(
                        (line) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: InfoRow(
                            icon: AppIcons.bag,
                            text: line,
                            iconSize: iconSize,
                          ),
                        ),
                      ),

                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Two pill buttons side by side ─────────────────────────────────
          const SizedBox(height: 6),

          // ── Two pill buttons ──────────────────────────────────────────────
          Row(
            children: [
              // Start Navigation
              Expanded(
                child: SizedBox(
                  height: 30,
                  child: ElevatedButton(
                    // onPressed: () {
                    //   Get.toNamed(
                    //     AppRoutes.navigation,
                    //     arguments: {
                    //       'orderId': order.id,
                    //       'destLat': double.tryParse(order.latitude) ?? 0.0,
                    //       'destLng': double.tryParse(order.longitude) ?? 0.0,
                    //     },
                    //   );
                    // },
                    onPressed: () {
                      Get.toNamed(
                        AppRoutes.navigation,
                        arguments: {
                          'orderId': order.id,
                          'destLat': double.tryParse(order.latitude) ?? 0.0,
                          'destLng': double.tryParse(order.longitude) ?? 0.0,
                          'orderType': 'nearest', // ← add this
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: const StadiumBorder(),
                      minimumSize: const Size(0, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          AppIcons.map,
                          width: 12,
                          height: 12,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Navigate',
                            style: AppTextStyles.buttonSmall.copyWith(
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Call Customer
              Expanded(
                child: SizedBox(
                  height: 30,
                  child: OutlinedButton(
                    onPressed: () async {
                      final url = Uri.parse('tel:${order.phoneNumber}');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1,
                      ),
                      shape: const StadiumBorder(),
                      minimumSize: const Size(0, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          AppIcons.phone,
                          width: 12,
                          height: 12,
                          colorFilter: const ColorFilter.mode(
                            AppColors.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Call',
                            style: AppTextStyles.buttonSmall.copyWith(
                              color: AppColors.primary,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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

// ── Circle image ──────────────────────────────────────────────────────────────
class _CircleImage extends StatelessWidget {
  const _CircleImage({required this.size, this.imageUrl});

  final double size;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                ImageUtils.getFullUrl(imageUrl) ?? '',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: AppColors.primarySurface,
    child: Center(
      child: Icon(
        Icons.water_drop_rounded,
        color: AppColors.primary,
        size: size * 0.45,
      ),
    ),
  );
}
