import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:axa_driver/leave/controller/leave_controller.dart';
import 'package:axa_driver/leave/view/leave_form_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeaveListView extends StatelessWidget {
  const LeaveListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LeaveController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        title: Text('My Leaves', style: AppTextStyles.headingMedium),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.leaves.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.error.value.isNotEmpty && controller.leaves.isEmpty) {
          return Center(
            child: GestureDetector(
              onTap: controller.fetchLeaves,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.refresh_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Try again',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.fetchLeaves,
          child: CustomScrollView(
            slivers: [
              // ── Summary strip ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Row(
                    children: [
                      _StatTile(
                        label: 'Total',
                        value: controller.leaves.length.toString(),
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      _StatTile(
                        label: 'Approved',
                        value: controller.leaves
                            .where((l) => l.status.toLowerCase() == 'approved')
                            .length
                            .toString(),
                        color: AppColors.statusApproved,
                      ),
                      const SizedBox(width: 8),
                      _StatTile(
                        label: 'Pending',
                        value: controller.leaves
                            .where((l) => l.status.toLowerCase() == 'pending')
                            .length
                            .toString(),
                        color: AppColors.statusProcessing,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Filter chips ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Obx(
                  () => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      children: ['All', 'Pending', 'Approved', 'Rejected'].map((
                        f,
                      ) {
                        final isActive = controller.selectedFilter.value == f;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () => controller.selectedFilter.value = f,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.primary.withOpacity(0.1)
                                    : AppColors.white,
                                border: Border.all(
                                  color: isActive
                                      ? AppColors.primary
                                      : AppColors.divider,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                f,
                                style: AppTextStyles.labelSmall.copyWith(
                                  fontSize: 11,
                                  color: isActive
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontWeight: isActive
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              // ── Empty state ────────────────────────────────────────────
              if (controller.filteredLeaves.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.inbox_rounded,
                          size: 44,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No leaves found',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Pull down to refresh',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // ── Leave list ───────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: Obx(
                    () => SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final leave = controller.filteredLeaves[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: AppShadows.card,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── Accent bar ──────────────────
                                Container(
                                  width: 3,
                                  height: 40,
                                  margin: const EdgeInsets.only(top: 2),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(leave.status),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // ── Content ─────────────────────
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${leave.formattedStartDate} – ${leave.formattedEndDate}',
                                              style: AppTextStyles.labelMedium
                                                  .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 7,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(
                                                leave.status,
                                              ).withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              leave.status.toUpperCase(),
                                              style: AppTextStyles.labelSmall
                                                  .copyWith(
                                                    fontSize: 10,
                                                    color: _getStatusColor(
                                                      leave.status,
                                                    ),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        leave.reason,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _dayCount(leave),
                                        style: AppTextStyles.labelSmall
                                            .copyWith(
                                              fontSize: 10,
                                              color: AppColors.textHint,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),

                                // ── Action icons ─────────────────
                                if (leave.status.toLowerCase() !=
                                    'approved') ...[
                                  const SizedBox(width: 4),
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: 26,
                                        height: 26,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            size: 14,
                                            color: AppColors.primary,
                                          ),
                                          onPressed: () => Get.to(
                                            () => const LeaveFormView(),
                                            arguments: leave,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 26,
                                        height: 26,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            size: 14,
                                            color: AppColors.statusCancelled,
                                          ),
                                          onPressed: () => _confirmDelete(
                                            context,
                                            controller,
                                            leave.id!,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }, childCount: controller.filteredLeaves.length),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const LeaveFormView()),
        backgroundColor: AppColors.primary,
        label: Text(
          'Apply for Leave',
          style: AppTextStyles.labelMedium.copyWith(color: AppColors.white),
        ),
      ),
    );
  }

  String _dayCount(leave) {
    try {
      final start = DateTime.parse(leave.startDate);
      final end = DateTime.parse(leave.endDate);
      final days = end.difference(start).inDays + 1;
      return '$days ${days == 1 ? 'day' : 'days'}';
    } catch (_) {
      return '';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.statusApproved;
      case 'rejected':
        return AppColors.statusCancelled;
      case 'pending':
      default:
        return AppColors.statusProcessing;
    }
  }

  void _confirmDelete(
    BuildContext context,
    LeaveController controller,
    int id,
  ) {
    final isDeleting = false.obs;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Obx(
          () => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: isDeleting.value
                  ? const SizedBox(
                      height: 80,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Delete Leave', style: AppTextStyles.headingSmall),
                        const SizedBox(height: 8),
                        Text(
                          'Are you sure you want to delete this leave application?',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 38,
                                child: OutlinedButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.textSecondary,
                                    side: BorderSide(
                                      color: AppColors.textSecondary
                                          .withOpacity(0.4),
                                    ),
                                    shape: const StadiumBorder(),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 38,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    isDeleting.value = true;
                                    await controller.deleteLeave(id);
                                    if (dialogContext.mounted) {
                                      Navigator.of(dialogContext).pop();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.statusCancelled,
                                    foregroundColor: AppColors.white,
                                    elevation: 0,
                                    shape: const StadiumBorder(),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Delete',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

// ── Stat tile widget ──────────────────────────────────────────────────────────
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.headingMedium.copyWith(color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
