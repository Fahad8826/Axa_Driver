import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:axa_driver/navigation/controller/navigation_controller.dart';
import 'package:axa_driver/navigation/model/order_detail_model.dart';
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
          Obx(
            () => GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(ctrl.destLat, ctrl.destLng),
                zoom: 14,
              ),
              onMapCreated: ctrl.onMapCreated,
              markers: ctrl.markers.toSet(),
              polylines: ctrl.polylines.toSet(),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
          ),

          // ── Back button & Recenter ─────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MapFab(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Get.back(),
                  ),
                  _MapFab(
                    icon: Icons.my_location_rounded,
                    onTap: ctrl.centerOnDestination,
                    iconColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),

          // ── Floating STATS Card ────────────────────────────────────────────
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
                        () => _StatItem(
                          label: 'Distance',
                          value: ctrl.distance.value,
                          icon: Icons.directions_car_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 32,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        color: AppColors.divider,
                      ),
                      Obx(
                        () => _StatItem(
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

          // ── Bottom sheet ───────────────────────────────────────────────────
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
                          color: AppColors.primary),
                    );
                  }
                  if (ctrl.error.value.isNotEmpty) {
                    return _ErrorState(
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
//  Error State
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.statusCancelledSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.statusCancelled,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: AppTextStyles.headingSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 140,
              height: AppDimens.buttonHeightSmall,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Map FAB button
// ─────────────────────────────────────────────────────────────────────────────
class _MapFab extends StatelessWidget {
  const _MapFab({
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.textPrimary,
  });
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: AppShadows.card,
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Stat Item
// ─────────────────────────────────────────────────────────────────────────────
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              Text(
                value,
                style: AppTextStyles.labelLarge.copyWith(
                  height: 1.2,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
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
  });

  final OrderDetailModel order;
  final ScrollController scrollController;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        // ── Drag Handle ───────────────────────────────────────────────────
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

        // ── Header: Title + Status + Buttons ──────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title & Status
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

                // Action Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Navigate button
                    _ActionButton(
                      label: 'Navigate',
                      icon: Icons.navigation_rounded,
                      onPressed: onNavigate,
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shadowColor: AppColors.primary.withOpacity(0.35),
                    ),
                    const SizedBox(width: 8),
                    // Scanner button — glass green effect
                    _ScannerButton(
                      onPressed: () => Get.toNamed("/scanner"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Divider ───────────────────────────────────────────────────────
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, thickness: 1, color: AppColors.divider),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 14)),

        // ── Customer Details Card ─────────────────────────────────────────
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
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // ── Order Details Card ────────────────────────────────────────────
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
//  Action Button
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
        elevation: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.pressed) ? 0 : 3),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Scanner Button — Glass Green Effect
// ─────────────────────────────────────────────────────────────────────────────
class _ScannerButton extends StatelessWidget {
  const _ScannerButton({required this.onPressed});
  final VoidCallback onPressed;

  // Glass green colors
  static const Color _glassGreen = Color(0xCC2E7D32);     // 80% opacity
  static const Color _borderGreen = Color(0x8881C784);    // light green border
  static const Color _iconGreen = Color(0xFFA5D6A7);      // soft light green icon
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
              // inner highlight for glass sheen
              BoxShadow(
                color: Colors.white.withOpacity(0.10),
                blurRadius: 1,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 15,
                  color: _iconGreen,
                ),
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

// ─────────────────────────────────────────────────────────────────────────────
//  Status Badge
// ─────────────────────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
//  Section Card
// ─────────────────────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
//  Detail Row
// ─────────────────────────────────────────────────────────────────────────────
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
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Order Item Row
// ─────────────────────────────────────────────────────────────────────────────
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
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 50,
              height: 50,
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _placeholder(),
                    )
                  : _placeholder(),
            ),
          ),
          const SizedBox(width: 12),

          // Details
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

// ─────────────────────────────────────────────────────────────────────────────
//  Item Data Row (label / value)
// ─────────────────────────────────────────────────────────────────────────────
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