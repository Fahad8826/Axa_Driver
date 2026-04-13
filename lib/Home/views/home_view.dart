import 'package:axa_driver/Home/controller/home_controller.dart';
import 'package:axa_driver/Home/model/home_model.dart';
import 'package:axa_driver/Home/views/widgets/current_delevery_card.dart';
import 'package:axa_driver/Home/views/widgets/error_view.dart';
import 'package:axa_driver/Home/views/widgets/next_delevery_card.dart';
import 'package:axa_driver/Home/views/widgets/summary_card.dart';
import 'package:axa_driver/Home/views/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../core/theme/utils/app_layout.dart';
import '../../../core/theme/apptheme.dart';


class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final layout = AppLayout.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (controller.error.value.isNotEmpty) {
            return ErrorView(
              message: controller.error.value,
              onRetry: controller.fetchTodaySummary,
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: controller.fetchTodaySummary,
            child: CustomScrollView(
              slivers: [
                // ── Top Bar ──────────────────────────────────────────────
                const SliverToBoxAdapter(child: TopBar()),

                // ── Summary Card ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      layout.hPad,
                      layout.innerGapMd,
                      layout.hPad,
                      0,
                    ),
                    child: SummaryCard(summary: controller.summary.value),
                  ),
                ),

                // ── Current Delivery Header ───────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      layout.hPad,
                      layout.sectionGap,
                      layout.hPad,
                      layout.innerGapSm,
                    ),
                    child: Text(
                      'Current Delivery',
                      style: AppTextStyles.headingLarge.copyWith(
                        fontSize: layout.titleFontSize,
                      ),
                    ),
                  ),
                ),

                // ── Current Delivery Card ─────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: layout.hPad),
                    child: controller.nearestOrder.value != null
                        ? CurrentDeliveryCard(
                            order: controller.nearestOrder.value!,
                            layout: layout,
                          )
                        : _EmptyCard(
                            message: controller.nearestOrderMessage.value,
                            layout: layout,
                          ),
                  ),
                ),

                // ── Next Deliveries Header ────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      layout.hPad,
                      layout.sectionGap,
                      layout.hPad,
                      layout.innerGapSm,
                    ),
                    child: Text(
                      'Next Deliveries',
                      style: AppTextStyles.headingLarge.copyWith(
                        fontSize: layout.titleFontSize,
                      ),
                    ),
                  ),
                ),

                // ── Next Deliveries List ──────────────────────────────────
                controller.todayOrders.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: layout.hPad,
                          ),
                          child: _EmptyCard(
                            message: 'No more deliveries today',
                            layout: layout,
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final isLast =
                              index == controller.todayOrders.length - 1;
                          if (isLast && controller.hasMoreOrders) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              controller.loadMoreOrders();
                            });
                          }
                          if (index == controller.todayOrders.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          }
                          return Padding(
                            padding: EdgeInsets.fromLTRB(
                              layout.hPad,
                              0,
                              layout.hPad,
                              isLast ? layout.sectionGap : layout.innerGapSm,
                            ),
                            child: NextDeliveryCard(
                              order: controller.todayOrders[index],
                              layout: layout,
                            ),
                          );
                        }, childCount: controller.todayOrders.length +
                            (controller.hasMoreOrders ? 1 : 0)),
                      ),
              ],
            ),
          );
        }),
      ),
    );
  }
}




// ─────────────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────────────

/// Returns the first non-null image URL across water_cans → products → addons.
String? firstImageUrl(OrderModel order) {
  for (final c in order.waterCans) {
    if (c.image != null && c.image!.isNotEmpty) return c.image;
  }
  for (final p in order.products) {
    if (p.image != null && p.image!.isNotEmpty) return p.image;
  }
  for (final a in order.addons) {
    if (a.image != null && a.image!.isNotEmpty) return a.image;
  }
  return null;
}


class InfoRow extends StatelessWidget {
  const InfoRow({super.key, 
    required this.icon,
    required this.text,
    required this.iconSize,
    this.isTitle = false,
    this.customColor,
    this.bold = false,
  });

  final String icon;
  final String text;
  final double iconSize;
  final bool isTitle;
  final Color? customColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final iconColor = isTitle
        ? AppColors.primary
        : (customColor ?? AppColors.textSecondary);

    final textStyle = isTitle
        ? AppTextStyles.headingSmall.copyWith(color: AppColors.primary)
        : bold
        ? AppTextStyles.bodyMedium.copyWith(
            color: customColor ?? AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          )
        : AppTextStyles.bodyMedium;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: SvgPicture.asset(
            icon,
            width: iconSize,
            height: iconSize,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: textStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message, required this.layout});
  final String message;
  final AppLayout layout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: layout.sectionGap),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_rounded,
            size: layout.productImageSm * 0.55,
            color: AppColors.textHint,
          ),
          SizedBox(height: layout.innerGapSm),
          Text(message, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
