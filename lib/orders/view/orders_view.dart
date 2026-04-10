
import 'package:axa_driver/core/services/app_layout.dart';
import 'package:axa_driver/core/theme/app_icons.dart';
import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:axa_driver/orders/controller/orders_controller.dart';
import 'package:axa_driver/orders/model/orders_model.dart';
import 'package:axa_driver/orders/view/order_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();
    final layout = AppLayout.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text('My Deliveries', style: AppTextStyles.headingMedium),
      ),
      body: Column(
        children: [
          // ── Search + Filter bar ──────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              layout.hPad,
              layout.innerGapMd,
              layout.hPad,
              layout.innerGapSm,
            ),
            child: Row(
              children: [
                // Search field — pill shape, grey fill
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: TextField(
                      onChanged: controller.onSearchChanged,
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search orders...',
                        hintStyle: AppTextStyles.inputHint,
                        filled: true,
                        fillColor: AppColors.inputFill,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 0),
                        prefixIcon: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 14),
                          child: SvgPicture.asset(
                            AppIcons.search,
                            width: 18,
                            height: 18,
                            colorFilter: const ColorFilter.mode(
                              AppColors.textHint,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 46,
                          minHeight: 46,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Filter button — blue pill square
                _FilterButton(controller: controller),
              ],
            ),
          ),

          // ── Orders list ──────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              }

              if (controller.error.value.isNotEmpty) {
                return _ErrorView(
                  message: controller.error.value,
                  onRetry: () => controller.fetchOrders(reset: true),
                );
              }

              if (controller.orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inbox_rounded,
                        size: 52,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No orders found',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => controller.fetchOrders(reset: true),
                child: ListView.separated(
                  controller: controller.scrollController,
                  padding: EdgeInsets.fromLTRB(
                    layout.hPad,
                    layout.innerGapSm,
                    layout.hPad,
                    layout.sectionGap,
                  ),
                  itemCount: controller.orders.length +
                      (controller.isLoadingMore.value ? 1 : 0),
                  separatorBuilder: (_, __) =>
                      SizedBox(height: layout.innerGapSm),
                  itemBuilder: (context, index) {
                    // Loading more indicator at bottom
                    if (index == controller.orders.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }

                    final order = controller.orders[index];
                    return _OrderCard(order: order, layout: layout);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Filter button with bottom sheet ──────────────────────────────────────────
class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.controller});
  final OrdersController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFilterSheet(context),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.tune_rounded,
          color: AppColors.white,
          size: 20,
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.surface,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Filter by Status', style: AppTextStyles.headingSmall),
            const SizedBox(height: 14),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: OrdersController.statusOptions.map((s) {
                  final isSelected = s == 'all'
                      ? controller.selectedStatus.value.isEmpty
                      : controller.selectedStatus.value == s;
                  return GestureDetector(
                    onTap: () {
                      controller.onStatusSelected(s);
                      Get.back();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.inputFill,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        s[0].toUpperCase() + s.substring(1),
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Single order card ─────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.layout});
  final OrdersModel order;
  final AppLayout layout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: info rows ──────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name — blue
                _IconText(
                  icon: AppIcons.profile,
                  text: order.customerName.isNotEmpty
                      ? order.customerName
                      : '—',
                  isTitle: true,
                ),
                const SizedBox(height: 4),
                // Address
                _IconText(
                  icon: AppIcons.map,
                  text: order.customerAddress.isNotEmpty
                      ? order.customerAddress
                      : '—',
                ),
                const SizedBox(height: 4),
                // Items summary
                _IconText(
                  icon: AppIcons.bag,
                  text: order.itemSummary,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ── Right: status chip + button ──────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Status chip
              _StatusChip(status: order.status),
              const SizedBox(height: 8),
              // View Details pill button
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(
                      () => OrderDetailView(orderId: order.id),
                      transition: Transition.rightToLeft,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: Text(
                    'View Details',
                    style: AppTextStyles.buttonSmall.copyWith(fontSize: 11),
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

// ── Status chip ───────────────────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: statusSurfaceColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: AppTextStyles.labelSmall.copyWith(
          color: statusColor(status),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Icon + text row (reusable inside card) ────────────────────────────────────
class _IconText extends StatelessWidget {
  const _IconText({
    required this.icon,
    required this.text,
    this.isTitle = false,
  });
  final String icon;
  final String text;
  final bool isTitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          width: 13,
          height: 13,
          colorFilter: ColorFilter.mode(
            isTitle ? AppColors.primary : AppColors.textSecondary,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            style: isTitle
                ? AppTextStyles.headingSmall
                    .copyWith(color: AppColors.primary, fontSize: 13)
                : AppTextStyles.bodyMedium.copyWith(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 48, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(message,
                style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: const StadiumBorder(),
                minimumSize: const Size(120, 40),
              ),
              child: Text('Retry', style: AppTextStyles.buttonSmall),
            ),
          ],
        ),
      ),
    );
  }
}