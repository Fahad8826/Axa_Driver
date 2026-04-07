import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:axa_driver/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    final mq = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text('Edit Profile', style: AppTextStyles.headingMedium),
        actions: [
          Obx(
            () => TextButton(
              onPressed:
                  controller.isUpdating.value ? null : controller.updateProfile,
              child: controller.isUpdating.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Text(
                      'Save',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          20,
          24,
          20,
          mq.viewInsets.bottom + 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              icon: Icons.person_outline_rounded,
              label: 'Personal Info',
            ),
            const SizedBox(height: 16),
            _EditField(
              label: 'Full Name',
              ctrl: controller.nameCtrl,
              icon: Icons.badge_outlined,
            ),
            _EditField(
              label: 'Email Address',
              ctrl: controller.emailCtrl,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),

            _SectionHeader(
              icon: Icons.directions_car_outlined,
              label: 'Vehicle Details',
            ),
            const SizedBox(height: 16),
            _EditField(
              label: 'Vehicle Number',
              ctrl: controller.vehicleNumberCtrl,
              icon: Icons.pin_outlined,
              inputFormatters: true,
            ),
            _EditField(
              label: 'Vehicle Model',
              ctrl: controller.vehicleModelCtrl,
              icon: Icons.commute_outlined,
            ),
            _EditField(
              label: 'Owner Name',
              ctrl: controller.vehicleOwnerCtrl,
              icon: Icons.person_pin_outlined,
            ),
            const SizedBox(height: 8),
            _SectionHeader(
              icon: Icons.account_balance_outlined,
              label: 'Bank Details',
            ),
            const SizedBox(height: 16),
            _EditField(
              label: 'Account Number',
              ctrl: controller.accountNumberCtrl,
              icon: Icons.credit_card_outlined,
              keyboardType: TextInputType.number,
            ),
            _EditField(
              label: 'Bank Name',
              ctrl: controller.bankNameCtrl,
              icon: Icons.account_balance_outlined,
            ),
            _EditField(
              label: 'Branch Name',
              ctrl: controller.branchNameCtrl,
              icon: Icons.location_city_outlined,
            ),
            _EditField(
              label: 'IFSC Code',
              ctrl: controller.ifscCodeCtrl,
              icon: Icons.tag_outlined,
              inputFormatters: true,
            ),
            const SizedBox(height: 32),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Text(label, style: AppTextStyles.headingSmall),
        ],
      );
}

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final IconData icon;
  final TextInputType keyboardType;
  final bool inputFormatters;

  const _EditField({
    required this.label,
    required this.ctrl,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          textCapitalization: inputFormatters
              ? TextCapitalization.characters
              : TextCapitalization.none,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
            labelStyle: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      );
}

