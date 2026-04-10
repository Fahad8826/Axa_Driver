import 'package:axa_driver/Home/model/home_model.dart';
import 'package:axa_driver/Home/views/home_view.dart';
import 'package:axa_driver/core/services/app_layout.dart';
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
      padding: const EdgeInsets.all(12),
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

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InfoRow(
                      icon: AppIcons.profile,
                      text: order.customerName.isNotEmpty
                          ? order.customerName
                          : '—',
                      isTitle: true,
                      iconSize: iconSize,
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

          const SizedBox(height: 12),

          // ── Two pill buttons side by side ─────────────────────────────────
          Row(
            children: [
              // Start Navigation — filled blue pill, Expanded
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.toNamed(
                        AppRoutes.navigation,
                        arguments: {
                          'orderId': order.id,
                          'destLat':
                              double.tryParse(order.latitude) ?? 0.0,
                          'destLng':
                              double.tryParse(order.longitude) ?? 0.0,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      // Pill shape
                      shape: const StadiumBorder(),
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          AppIcons.map,
                          width: 14,
                          height: 14,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            'Start Navigation',
                            style: AppTextStyles.buttonSmall
                                .copyWith(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Call Customer — outlined blue pill, Expanded
              Expanded(
                child: SizedBox(
                  height: 38,
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
                        width: 1.5,
                      ),
                      // Pill shape
                      shape: const StadiumBorder(),
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          AppIcons.phone,
                          width: 14,
                          height: 14,
                          colorFilter: const ColorFilter.mode(
                            AppColors.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            'Call Customer',
                            style: AppTextStyles.buttonSmall.copyWith(
                              color: AppColors.primary,
                              fontSize: 12,
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
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
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