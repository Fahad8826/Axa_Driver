
import 'package:axa_driver/core/services/app_layout.dart';
import 'package:axa_driver/core/theme/app_icons.dart';
import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:axa_driver/orders/controller/orders_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class OrderDetailView extends StatelessWidget {
  const OrderDetailView({super.key, required this.orderId});
  final int orderId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();
    final layout = AppLayout.of(context);

    // Fetch detail when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchOrderDetail(orderId);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded,
              size: 28, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text('Delivery Details', style: AppTextStyles.headingMedium),
      ),
      body: Obx(() {
        if (controller.isDetailLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.detailError.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off_rounded,
                      size: 48, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  Text(controller.detailError.value,
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.fetchOrderDetail(orderId),
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

        final order = controller.orderDetail.value;
        if (order == null) return const SizedBox.shrink();

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            layout.hPad,
            layout.sectionGap,
            layout.hPad,
            layout.sectionGap,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Customer Details ───────────────────────────────────────
              Text('Customer Details',
                  style: AppTextStyles.headingMedium),
              SizedBox(height: layout.innerGapSm),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.profile,
                          width: 16,
                          height: 16,
                          colorFilter: const ColorFilter.mode(
                            AppColors.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          order.customerName.isNotEmpty
                              ? order.customerName
                              : '—',
                          style: AppTextStyles.headingSmall
                              .copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Address
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: SvgPicture.asset(
                            AppIcons.map,
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                              AppColors.textSecondary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            order.customerAddress.isNotEmpty
                                ? order.customerAddress
                                : '—',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: layout.sectionGap),

              // ── Order Details ──────────────────────────────────────────
              Text('Order Details', style: AppTextStyles.headingMedium),
              SizedBox(height: layout.innerGapSm),

              // Water cans
              ...order.waterCans.map(
                (can) => Padding(
                  padding: EdgeInsets.only(bottom: layout.innerGapSm),
                  child: _OrderItemCard(
                    imageUrl: can.image,
                    itemName: '${can.litres}L ${can.name}',
                    quantity: '${can.quantity} Cans',
                  ),
                ),
              ),

              // Products
              ...order.products.map(
                (p) => Padding(
                  padding: EdgeInsets.only(bottom: layout.innerGapSm),
                  child: _OrderItemCard(
                    imageUrl: p.image,
                    itemName: p.name,
                    quantity: '${p.quantity} Nos',
                  ),
                ),
              ),

              // Addons
              ...order.addons.map(
                (a) => Padding(
                  padding: EdgeInsets.only(bottom: layout.innerGapSm),
                  child: _OrderItemCard(
                    imageUrl: a.image,
                    itemName: a.name,
                    quantity: '1 Nos',
                  ),
                ),
              ),

              if (order.waterCans.isEmpty &&
                  order.products.isEmpty &&
                  order.addons.isEmpty)
                _SectionCard(
                  child: Center(
                    child: Text('No items',
                        style: AppTextStyles.bodyMedium),
                  ),
                ),

              SizedBox(height: layout.sectionGap),

              // ── Delivery Confirmation ──────────────────────────────────
              Text('Delivery Confirmation',
                  style: AppTextStyles.headingMedium),
              SizedBox(height: layout.innerGapSm),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('QR Code',
                        style: AppTextStyles.headingSmall),
                    const SizedBox(height: 4),
                    Text(
                      'This delivery is confirmed through QR Code Verification.',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),

              SizedBox(height: layout.sectionGap),

              // ── Back button ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  child: Text('Back', style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── White section card wrapper ────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }
}

// ── Single order item row card ────────────────────────────────────────────────
class _OrderItemCard extends StatelessWidget {
  const _OrderItemCard({
    required this.itemName,
    required this.quantity,
    this.imageUrl,
  });

  final String itemName;
  final String quantity;
  final String? imageUrl;

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
        children: [
          // Product image — rounded rect
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 52,
              height: 52,
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imgPlaceholder(),
                    )
                  : _imgPlaceholder(),
            ),
          ),

          const SizedBox(width: 14),

          // Item / Quantity labels + values
          Expanded(
            child: Column(
              children: [
                // Item row
                Row(
                  children: [
                    SizedBox(
                      width: 64,
                      child: Text('Item',
                          style: AppTextStyles.bodyMedium),
                    ),
                    Expanded(
                      child: Text(
                        itemName,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Quantity row
                Row(
                  children: [
                    SizedBox(
                      width: 64,
                      child: Text('Quantity',
                          style: AppTextStyles.bodyMedium),
                    ),
                    Expanded(
                      child: Text(
                        quantity,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
        color: AppColors.primarySurface,
        child: const Center(
          child: Icon(
            Icons.water_drop_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        ),
      );
}