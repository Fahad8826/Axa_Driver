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
          // FIX: Use Obx so the map rebuilds when RxSet markers/polylines change.
          // GetBuilder only responds to update() calls — it ignores Rx observables,
          // which is why the polyline never appeared even though 312 points were fetched.
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
              padding: const EdgeInsets.all(12),
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
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppShadows.card,
                  ),
                  child: Row(
                    children: [
                      Obx(() => _StatItem(
                        label: 'Distance',
                        value: ctrl.distance.value,
                        icon: Icons.directions_car_rounded,
                        color: AppColors.primary,
                      )),
                      Container(
                        width: 1,
                        height: 30,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        color: AppColors.divider,
                      ),
                      Obx(() => _StatItem(
                        label: 'Duration',
                        value: ctrl.duration.value,
                        icon: Icons.access_time_rounded,
                        color: AppColors.statusPending,
                      )),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom sheet ───────────────────────────────────────────────────
          DraggableScrollableSheet(
            initialChildSize: 0.42,
            minChildSize: 0.18,
            maxChildSize: 0.88,
            snap: true,
            snapSizes: const [0.18, 0.42, 0.88],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: AppShadows.cardHover,
                ),
                child: Obx(() {
                  if (ctrl.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }
                  if (ctrl.error.value.isNotEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.statusCancelled,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              ctrl.error.value,
                              style: AppTextStyles.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: ctrl.fetchOrderDetail,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
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
//  Map FAB button
// ─────────────────────────────────────────────────────────────────────────────
class _MapFab extends StatelessWidget {
  const _MapFab({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: AppShadows.card,
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}

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
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              Text(value, style: AppTextStyles.labelLarge.copyWith(height: 1)),
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
              const SizedBox(height: 14),
            ],
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current Delivery', style: AppTextStyles.headingMedium),
                      const SizedBox(height: 4),
                      _StatusBadge(status: order.status),
                    ],
                  ),
                ),
                // ElevatedButton.icon(
                //   onPressed: onNavigate,
                //   icon: const Icon(Icons.navigation_rounded, size: 18),
                //   label: const Text('Navigate'),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: AppColors.primary,
                //     minimumSize: const Size(60, 28),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //   ),
                // ),



              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SectionCard(
              title: 'Customer Details',
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

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SectionCard(
              title: 'Order Details',
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

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
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
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

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
          Text(title, style: AppTextStyles.headingSmall),
          const SizedBox(height: 10),
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
                ? AppTextStyles.headingSmall.copyWith(color: AppColors.primary)
                : AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.label, required this.sub, this.imageUrl});
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
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 48,
              height: 48,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Item', style: AppTextStyles.bodySmall),
                    Flexible(
                      child: Text(
                        label,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Qty', style: AppTextStyles.bodySmall),
                    Text(
                      sub,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textPrimary,
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

  Widget _placeholder() => Container(
    color: AppColors.primarySurface,
    child: const Icon(
      Icons.water_drop_rounded,
      color: AppColors.primary,
      size: 22,
    ),
  );
}