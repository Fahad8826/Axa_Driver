import 'package:axa_driver/core/utils/date_utils.dart';
import 'package:axa_driver/core/utils/image_utils.dart';
import 'package:axa_driver/core/theme/utils/app_layout.dart';
import 'package:axa_driver/core/theme/app_icons.dart';
import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:axa_driver/orders/controller/orders_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailView extends StatelessWidget {
  const OrderDetailView({super.key, required this.orderId});
  final int orderId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();
    final layout = AppLayout.of(context);

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
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFEBEE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.wifi_off_rounded,
                        size: 30, color: AppColors.statusCancelled),
                  ),
                  const SizedBox(height: 14),
                  Text('Failed to load order',
                      style: AppTextStyles.headingSmall),
                  const SizedBox(height: 6),
                  Text(controller.detailError.value,
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 130,
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () => controller.fetchOrderDetail(orderId),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: Text('Retry', style: AppTextStyles.buttonSmall),
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
              // ── Customer Details ─────────────────────────────────────────
              Text('Customer Details', style: AppTextStyles.headingMedium),
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
                        Expanded(
                          child: Text(
                            order.customerName.isNotEmpty
                                ? order.customerName
                                : '—',
                            style: AppTextStyles.headingSmall
                                .copyWith(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

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
                    const SizedBox(height: 8),

                    // Scheduled Date
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppDateUtils.formatFullDate(order.scheduledDate),
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ── Action Buttons Row ─────────────────────────────────
                    const Divider(
                        height: 1, thickness: 1, color: AppColors.divider),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        // Navigate button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final destLat =
                                  double.tryParse(order.latitude ?? '0') ?? 0.0;
                              final destLng =
                                  double.tryParse(order.longitude ?? '0') ?? 0.0;
                                  
                              if (destLat == 0.0 && destLng == 0.0) {
                                Get.snackbar('Error', 'Invalid destination coordinates', 
                                  snackPosition: SnackPosition.BOTTOM);
                                return;
                              }
                              
                              final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$destLat,$destLng');
                              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                Get.snackbar('Error', 'Could not open maps', 
                                  snackPosition: SnackPosition.BOTTOM);
                              }
                            },
                            icon: const Icon(Icons.navigation_rounded,
                                size: 16, color: Colors.white),
                            label: Text(
                              'Navigate',
                              style: AppTextStyles.labelMedium
                                  .copyWith(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              minimumSize: const Size(0, 42),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              shadowColor:
                                  AppColors.primary.withOpacity(0.35),
                            ).copyWith(
                              elevation: WidgetStateProperty.resolveWith(
                                (s) => s.contains(WidgetState.pressed) ? 0 : 3,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Scanner button — glass green
                        Expanded(
                          child: _GlassScannerButton(
                            onPressed: () => Get.toNamed("/scanner"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: layout.sectionGap),

              // ── Order Details ────────────────────────────────────────────
              Text('Order Details', style: AppTextStyles.headingMedium),
              SizedBox(height: layout.innerGapSm),

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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('No items', style: AppTextStyles.bodyMedium),
                    ),
                  ),
                ),

              SizedBox(height: layout.sectionGap),

              // ── Delivery Confirmation ────────────────────────────────────
              Text('Delivery Confirmation',
                  style: AppTextStyles.headingMedium),
              SizedBox(height: layout.innerGapSm),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status row
                    Row(
                      children: [
                        // Status icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: statusSurfaceColor(order.status),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _statusIcon(order.status),
                            size: 20,
                            color: statusColor(order.status),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order Status',
                                style: AppTextStyles.bodySmall,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _statusLabel(order.status),
                                style: AppTextStyles.headingSmall.copyWith(
                                  color: statusColor(order.status),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: statusSurfaceColor(order.status),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            order.status.capitalizeFirst ?? order.status,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: statusColor(order.status),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const Divider(
                        height: 1, thickness: 1, color: AppColors.divider),
                    const SizedBox(height: 12),

                    // Description line
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.qr_code_rounded,
                            size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _statusDescription(order.status),
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      ],
                    ),

                    if (order.status.toLowerCase() != 'delivered' && 
                        order.status.toLowerCase() != 'cancelled') ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: OutlinedButton.icon(
                          onPressed: () => _showImagePicker(context, controller, order.id),
                          icon: const Icon(Icons.camera_alt_outlined, size: 18),
                          label: Obx(() => controller.isUploadingProof.value
                              ? const SizedBox(
                                  width: 16, height: 16, 
                                  child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Upload Photo Proof')),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Show delivered time if available
                    if (order.deliveredAt != null &&
                        order.deliveredAt!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            'Delivered: ',
                            style: AppTextStyles.bodyMedium,
                          ),
                          Expanded(
                            child: Text(
                              _formatDeliveredAt(order.deliveredAt!),
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: layout.sectionGap),

              // ── Back button ──────────────────────────────────────────────
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

  // ── Status helpers ─────────────────────────────────────────────────────────
  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.hourglass_empty_rounded;
      case 'assigned':
      case 'new':
        return Icons.local_shipping_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return 'Delivery Completed';
      case 'pending':
        return 'Awaiting Delivery';
      case 'assigned':
        return 'Out for Delivery';
      case 'new':
        return 'New Order';
      case 'cancelled':
        return 'Order Cancelled';
      default:
        return status.capitalizeFirst ?? status;
    }
  }

  /// Trims ISO datetime like "2024-11-05T14:32:00Z" → "05 Nov 2024, 2:32 PM"
  String _formatDeliveredAt(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      const months = [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ];
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour < 12 ? 'AM' : 'PM';
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $h:$m $ampm';
    } catch (_) {
      // If parsing fails, just truncate the raw string
      return raw.length > 20 ? '${raw.substring(0, 20)}…' : raw;
    }
  }

  void _showImagePicker(BuildContext context, OrdersController controller, int orderId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Take a Photo'),
              onTap: () async {
                Get.back();
                final picker = ImagePicker();
                final file = await picker.pickImage(source: ImageSource.camera);
                if (file != null) {
                  controller.uploadDeliveryProof(orderId, file.path);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Get.back();
                final picker = ImagePicker();
                final file = await picker.pickImage(source: ImageSource.gallery);
                if (file != null) {
                  controller.uploadDeliveryProof(orderId, file.path);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _statusDescription(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return 'This order has been successfully delivered and confirmed via QR Code.';
      case 'pending':
        return 'This order is pending. Scan the customer\'s QR Code upon arrival to confirm delivery.';
      case 'assigned':
      case 'new':
        return 'You are assigned to this delivery. Navigate to the customer and scan the QR Code to confirm.';
      case 'cancelled':
        return 'This order has been cancelled and no further action is required.';
      default:
        return 'Scan the customer\'s QR Code to confirm this delivery.';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Glass Scanner Button
// ─────────────────────────────────────────────────────────────────────────────
class _GlassScannerButton extends StatelessWidget {
  const _GlassScannerButton({required this.onPressed});
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
                color: const Color(0xFF2E7D32).withOpacity(0.28),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.10),
                blurRadius: 1,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: SizedBox(
            height: 42,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 16,
                  color: _iconGreen,
                ),
                const SizedBox(width: 6),
                Text(
                  'Scanner',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: Colors.white),
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
//  Section Card
// ─────────────────────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
//  Order Item Card
// ─────────────────────────────────────────────────────────────────────────────
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
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 52,
              height: 52,
              child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
                    ImageUtils.getFullUrl(imageUrl) ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _imgPlaceholder(),
                  )
                : _imgPlaceholder(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 64,
                      child: Text('Item', style: AppTextStyles.bodyMedium),
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
                Row(
                  children: [
                    SizedBox(
                      width: 64,
                      child:
                          Text('Quantity', style: AppTextStyles.bodyMedium),
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