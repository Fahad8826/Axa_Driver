
import 'package:axa_driver/core/utils/date_utils.dart';
import 'package:axa_driver/core/utils/image_utils.dart';
import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:axa_driver/navigation/controller/navigation_controller.dart';
import 'package:axa_driver/navigation/model/order_detail_model.dart';
import 'package:axa_driver/navigation/view/widgets/error_state.dart';
import 'package:axa_driver/navigation/view/widgets/mapfab.dart';
import 'package:axa_driver/navigation/view/widgets/stat_iteam.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NavigationView extends StatelessWidget {
  const NavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<NavigationController>();

    return Scaffold(
      body: Stack(
        children: [
          // ── Full-screen Google Map ─────────────────────────────────────────
          Obx(() => GoogleMap(
                initialCameraPosition: CameraPosition(
                  // Use current destination if available, else world center
                  target: LatLng(
                    ctrl.orderDetail.value?.customerLat ?? 20.5937,
                    ctrl.orderDetail.value?.customerLng ?? 78.9629,
                  ),
                  zoom: 14,
                ),
                onMapCreated: ctrl.onMapCreated,
                markers: ctrl.markers.toSet(),
                polylines: ctrl.polylines.toSet(),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: true,
                trafficEnabled: true,
              )),

          // ── Top FAB Row ────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back
                  MapFab(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Get.back(),
                  ),
                  // Right-side cluster
                  Row(
                    children: [
                      // Refresh route button
                      Obx(() => MapFab(
                            icon: ctrl.isRouteLoading.value
                                ? Icons.hourglass_top_rounded
                                : Icons.refresh_rounded,
                            onTap: ctrl.isRouteLoading.value
                                ? () {}
                                : ctrl.refreshRoute,
                            iconColor: ctrl.isRouteLoading.value
                                ? AppColors.textSecondary
                                : AppColors.statusPending,
                          )),
                      const SizedBox(width: 8),
                      // Center on destination
                      MapFab(
                        icon: Icons.location_on_rounded,
                        onTap: ctrl.centerOnDestination,
                        iconColor: AppColors.statusCancelled,
                      ),
                      const SizedBox(width: 8),
                      // Center on driver
                      MapFab(
                        icon: Icons.my_location_rounded,
                        onTap: ctrl.centerOnDriver,
                        iconColor: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Route loading banner ───────────────────────────────────────────
          Obx(() {
            if (!ctrl.isRouteLoading.value) return const SizedBox.shrink();
            return Positioned(
              top: 90,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppShadows.card,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Calculating route...',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // ── Floating Stats Card ────────────────────────────────────────────
          Positioned(
            top: 100,
            left: 16,
            right: 16,
            child: Obx(
              () => AnimatedOpacity(
                opacity: ctrl.isLoading.value ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: AppShadows.card,
                  ),
                  child: Row(
                    children: [
                      Obx(
                        () => StatItem(
                          label: 'Distance',
                          value: ctrl.distance.value,
                          icon: Icons.directions_car_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 32,
                        margin:
                            const EdgeInsets.symmetric(horizontal: 16),
                        color: AppColors.divider,
                      ),
                      Obx(
                        () => StatItem(
                          label: 'Duration',
                          value: ctrl.duration.value,
                          icon: Icons.access_time_rounded,
                          color: AppColors.statusPending,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom Sheet ───────────────────────────────────────────────────
          DraggableScrollableSheet(
            initialChildSize: 0.44,
            minChildSize: 0.18,
            maxChildSize: 0.90,
            snap: true,
            snapSizes: const [0.18, 0.44, 0.90],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(26)),
                  boxShadow: AppShadows.cardHover,
                ),
                child: Obx(() {
                  if (ctrl.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }
                  if (ctrl.error.value.isNotEmpty) {
                    return ErrorState(
                      message: ctrl.error.value,
                      onRetry: ctrl.fetchOrderDetail,
                    );
                  }
                  final order = ctrl.orderDetail.value;
                  if (order == null) return const SizedBox.shrink();
                  return _BottomSheetContent(
                    order: order,
                    scrollController: scrollController,
                    onNavigate: ctrl.launchGoogleMaps,
                    ctrl: ctrl, 
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}






// ─────────────────────────────────────────────────────────────────────────────
//  Bottom Sheet Content
// ─────────────────────────────────────────────────────────────────────────────
class _BottomSheetContent extends StatelessWidget {
  const _BottomSheetContent({
    required this.order,
    required this.scrollController,
    required this.onNavigate,
    required this.ctrl,
  });
  final OrderDetailModel order;
  final ScrollController scrollController;
  final VoidCallback onNavigate;
  final NavigationController ctrl;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        // Drag handle
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Delivery',
                        style: AppTextStyles.headingMedium,
                      ),
                      const SizedBox(height: 5),
                      _StatusBadge(status: order.status),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionButton(
                      label: 'Navigate',
                      icon: Icons.navigation_rounded,
                      onPressed: onNavigate,
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shadowColor: AppColors.primary.withOpacity(0.35),
                    ),
                    const SizedBox(width: 8),
                    _ScannerButton(
                      onPressed: () => Get.toNamed('/scanner'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, thickness: 1, color: AppColors.divider),
          ),
        ),

        // ── Mark as Picked button ──────────────────────────────────────────
        // ── Mark as Picked button ──────────────────────────────────────────
SliverToBoxAdapter(
  child: Obx(() {
    // Hide if already picked up this session OR status is already beyond assigned
    final status = order.status.toLowerCase();
    final alreadyPicked = status == 'picked' ||
        status == 'delivered' ||
        status == 'cancelled';

    if (ctrl.isPickedUp.value || alreadyPicked) {
      return const SizedBox(height: 14);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: ElevatedButton.icon(
          onPressed: ctrl.isMarkingPicked.value
              ? null
              : () async {
                  await ctrl.markAsPicked();
                  // Button auto-hides via isPickedUp flag after success
                },
          icon: ctrl.isMarkingPicked.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 18,
                  color: Colors.white,
                ),
          label: Text(
            'Mark as Picked',
            style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.statusPending,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }),
),

        const SliverToBoxAdapter(child: SizedBox(height: 14)),

        // Customer Details
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SectionCard(
              title: 'Customer Details',
              icon: Icons.person_outline_rounded,
              iconColor: AppColors.primary,
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.person_outline_rounded,
                    label: order.customerName,
                    isTitle: true,
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    icon: Icons.location_on_outlined,
                    label: order.customerAddress,
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: AppDateUtils.formatShortDate(order.scheduledDate),
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    icon: Icons.phone,
                    label: order.customerPhone,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // Order Details
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SectionCard(
              title: 'Order Details',
              icon: Icons.inventory_2_outlined,
              iconColor: AppColors.statusPending,
              child: Column(
                children: [
                  ...order.waterCans.map(
                    (c) => _OrderItemRow(
                      imageUrl: c.image,
                      label: c.name,
                      sub: '${c.quantity} × ${c.litres}L',
                    ),
                  ),
                  ...order.products.map(
                    (p) => _OrderItemRow(
                      imageUrl: p.image,
                      label: p.name,
                      sub: 'Qty: ${p.quantity}',
                    ),
                  ),
                  ...order.addons.map(
                    (a) => _OrderItemRow(
                      imageUrl: a.image,
                      label: a.name,
                      sub: 'Add-on',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 36)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Small reusable widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.shadowColor,
  });
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color shadowColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 15, color: foregroundColor),
      label: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(color: foregroundColor),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: 0,
        minimumSize: const Size(0, 38),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: shadowColor,
      ).copyWith(
        elevation: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.pressed) ? 0 : 3,
        ),
      ),
    );
  }
}

class _ScannerButton extends StatelessWidget {
  const _ScannerButton({required this.onPressed});
  final VoidCallback onPressed;

  static const Color _glassGreen = Color(0xCC2E7D32);
  static const Color _borderGreen = Color(0x8881C784);
  static const Color _iconGreen = Color(0xFFA5D6A7);
  static const Color _rippleGreen = Color(0x2281C784);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        splashColor: _rippleGreen,
        highlightColor: _rippleGreen,
        child: Ink(
          decoration: BoxDecoration(
            color: _glassGreen,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderGreen, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E7D32).withOpacity(0.30),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.qr_code_scanner_rounded,
                    size: 15, color: _iconGreen),
                const SizedBox(width: 6),
                Text(
                  'Scanner',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    final bg = statusSurfaceColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.capitalizeFirst ?? status,
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    required this.icon,
    required this.iconColor,
  });
  final String title;
  final Widget child;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: iconColor),
              const SizedBox(width: 7),
              Text(title, style: AppTextStyles.headingSmall),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    this.isTitle = false,
  });
  final IconData icon;
  final String label;
  final bool isTitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: isTitle ? AppColors.primary : AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: isTitle
                ? AppTextStyles.headingSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  )
                : AppTextStyles.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({
    required this.label,
    required this.sub,
    this.imageUrl,
  });
  final String label;
  final String sub;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 50,
              height: 50,
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(
                      ImageUtils.getFullUrl(imageUrl) ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                _ItemDataRow(label: 'Item', value: label),
                const SizedBox(height: 3),
                _ItemDataRow(label: 'Qty', value: sub),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.primarySurface,
        child: const Icon(
          Icons.water_drop_rounded,
          color: AppColors.primary,
          size: 22,
        ),
      );
}

class _ItemDataRow extends StatelessWidget {
  const _ItemDataRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}