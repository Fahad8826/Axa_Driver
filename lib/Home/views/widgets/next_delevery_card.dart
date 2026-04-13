import 'package:axa_driver/Home/model/home_model.dart';
import 'package:axa_driver/Home/views/home_view.dart';
import 'package:axa_driver/core/theme/utils/app_layout.dart';
import 'package:axa_driver/core/theme/app_icons.dart';
import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:axa_driver/core/services/routers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NextDeliveryCard extends StatelessWidget {
  const NextDeliveryCard({
    super.key,
    required this.order,
    required this.layout,
  });

  final OrderModel order;
  final AppLayout layout;

  @override
  Widget build(BuildContext context) {
    // Circle image — same size as Figma (~65px)
    final double imgSize = layout.productImageSm;
    const double iconSize = 14.0;
    final String? imageUrl = firstImageUrl(order);

    final List<String> itemLines = [
      ...order.waterCans.map((c) => '${c.quantity} × ${c.name}'),
      ...order.products.map((p) => '${p.quantity} × ${p.name}'),
      ...order.addons.map((a) => '${a.quantity} × ${a.name}'),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Circle image ───────────────────────────────────────────────
          _CircleImage(size: imgSize, imageUrl: imageUrl),

          const SizedBox(width: 12),

          // ── Info + button — Expanded prevents any overflow ─────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer name — blue, bold
                InfoRow(
                  icon: AppIcons.profile,
                  text: order.customerName.isNotEmpty
                      ? order.customerName
                      : '—',
                  isTitle: true,
                  iconSize: iconSize,
                ),
                const SizedBox(height: 4),

                // Address
                InfoRow(
                  icon: AppIcons.map,
                  text: order.address.isNotEmpty ? order.address : '—',
                  iconSize: iconSize,
                ),
                const SizedBox(height: 4),

                // Item lines
                if (itemLines.isEmpty)
                  InfoRow(
                    icon: AppIcons.bag,
                    text: '0 × items',
                    iconSize: iconSize,
                  )
                else
                  ...itemLines.map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: InfoRow(
                        icon: AppIcons.bag,
                        text: line,
                        iconSize: iconSize,
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                // ── Pill button — NOT full width, auto-sized ─────────────
                SizedBox(
                  height: 34,
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
                      // Pill shape — fully rounded
                      shape: const StadiumBorder(),
                      // Auto width based on content
                      minimumSize: const Size(0, 34),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: Text(
                      'Start Navigation',
                      style: AppTextStyles.buttonSmall.copyWith(
                        fontSize: 12,
                        color: AppColors.white,
                      ),
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

// ── Perfect circle image ──────────────────────────────────────────────────────
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