import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:axa_driver/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showEditModal(BuildContext context) {
  final ProfileController controller = Get.find<ProfileController>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    builder: (sheetContext) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (innerContext, scrollController) {
        // Read keyboard height from innerContext so it rebuilds live
        final double keyboardHeight =
            MediaQuery.of(innerContext).viewInsets.bottom;

        return Container(
          
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _modalHandle(),
              _modalHeader(
                title: 'Edit Profile',
                onClose: () => Get.back(),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding:
                      EdgeInsets.fromLTRB(20, 16, 20, keyboardHeight + 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _modalSectionHeader(
                        Icons.person_outline,
                        'Personal Info',
                      ),
                      const SizedBox(height: 12),
                      _editField(
                        label: 'Name',
                        ctrl: controller.nameCtrl,
                      ),
                      _editField(
                        label: 'Email',
                        ctrl: controller.emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 8),
                      _modalSectionHeader(
                        Icons.directions_car_outlined,
                        'Vehicle Details',
                      ),
                      const SizedBox(height: 12),
                      _editField(
                        label: 'Vehicle Number',
                        ctrl: controller.vehicleNumberCtrl,
                      ),
                      _editField(
                        label: 'Vehicle Model',
                        ctrl: controller.vehicleModelCtrl,
                      ),
                      _editField(
                        label: 'Owner Name',
                        ctrl: controller.vehicleOwnerCtrl,
                      ),
                      const SizedBox(height: 8),
                      _modalSectionHeader(
                        Icons.account_balance_outlined,
                        'Bank Details',
                      ),
                      const SizedBox(height: 12),
                      _editField(
                        label: 'Account Number',
                        ctrl: controller.accountNumberCtrl,
                        keyboardType: TextInputType.number,
                      ),
                      _editField(
                        label: 'Bank Name',
                        ctrl: controller.bankNameCtrl,
                      ),
                      _editField(
                        label: 'Branch Name',
                        ctrl: controller.branchNameCtrl,
                      ),
                      _editField(
                        label: 'IFSC Code',
                        ctrl: controller.ifscCodeCtrl,
                      ),
                      const SizedBox(height: 24),
                      Obx(
                        () => _primaryButton(
                          label: 'Save Changes',
                          isLoading: controller.isUpdating.value,
                          onPressed: controller.updateProfile,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}



Widget _modalHandle() => Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );

Widget _modalHeader({
  required String title,
  required VoidCallback onClose,
}) =>
    Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.headingMedium),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
          ),
        ],
      ),
    );

Widget _modalSectionHeader(IconData icon, String label) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: AppDimens.iconMd, color: AppColors.textPrimary),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.headingSmall),
        ],
      ),
    );

Widget _editField({
  required String label,
  required TextEditingController ctrl,
  TextInputType keyboardType = TextInputType.text,
}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: AppTextStyles.bodyMedium,
        decoration: _inputDecoration(label),
      ),
    );

InputDecoration _inputDecoration(String label) => InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );

Widget _primaryButton({
  required String label,
  required bool isLoading,
  required VoidCallback onPressed,
}) =>
    SizedBox(
      width: double.infinity,
      height: AppDimens.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(label, style: AppTextStyles.button),
      ),
    );