import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:axa_driver/core/theme/utils/app_erro_widget.dart';
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
        title: Text('Leaves', style: AppTextStyles.headingMedium),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          Obx(
            () => DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedFilter.value,
                icon: const Icon(Icons.filter_list, color: AppColors.primary),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                ),
                items: ['All', 'Pending', 'Approved', 'Rejected'].map((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    controller.selectedFilter.value = newValue;
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.leaves.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.error.value.isNotEmpty && controller.leaves.isEmpty) {
          return AppErrorWidget(
            message: controller.error.value,
            onRetry: controller.fetchLeaves,
          );
        }

        if (controller.filteredLeaves.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text('No leaves found', style: AppTextStyles.headingSmall),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.fetchLeaves,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: controller.filteredLeaves.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final leave = controller.filteredLeaves[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${leave.formattedStartDate} - ${leave.formattedEndDate}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              leave.status,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            leave.status.toUpperCase(),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: _getStatusColor(leave.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      leave.reason,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (leave.status.toLowerCase() != 'approved') ...[
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            onPressed: () {
                              Get.to(
                                () => const LeaveFormView(),
                                arguments: leave,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.statusCancelled,
                              size: 20,
                            ),
                            onPressed: () =>
                                _confirmDelete(context, controller, leave.id!),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const LeaveFormView());
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
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
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Leave', style: AppTextStyles.headingSmall),
        content: Text(
          'Are you sure you want to delete this leave application?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteLeave(id);
            },
            child: Text(
              'Delete',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.statusCancelled,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
