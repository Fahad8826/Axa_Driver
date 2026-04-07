import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:axa_driver/core/theme/utils/app_erro_widget.dart';
import 'package:axa_driver/profile/controller/profile_controller.dart';
import 'package:axa_driver/profile/model/profile_model.dart';
import 'package:axa_driver/profile/utils/shimmer.dart';
import 'package:axa_driver/profile/view/change_password.dart';
import 'package:axa_driver/profile/view/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileController());

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('My Profile', style: AppTextStyles.headingMedium),
      ),
      body: Obx(() {
        // ── Shimmer ──────────────────────────────────────────────────────
        if (controller.isLoading.value) {
          return ProfileShimmer(
            screenWidth: screenWidth,
            screenHeight: screenHeight,
          );
        }

        // ── Error ────────────────────────────────────────────────────────
        if (controller.error.value.isNotEmpty) {
          return AppErrorWidget(
            message: controller.error.value,
            onRetry: controller.fetchProfile,
          );
        }

        // ── Data ─────────────────────────────────────────────────────────
        final ProfileModel p = controller.profile.value!;

        return RefreshIndicator(
          // ← add this
          color: AppColors.primary,
          onRefresh: () async => await controller.fetchProfile(),
          child: SingleChildScrollView(
            // ← existing widget
            physics: const AlwaysScrollableScrollPhysics(), // ← add this
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.022,
            ),
            child: Column(
              children: [
                // ── Avatar + name card ──────────────────────────────────────
                _ProfileCard(
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.012),

                      // Tappable avatar with camera badge
                      GestureDetector(
                        onTap: () => _showAvatarOptions(context),
                        child: Stack(
                          children: [
                            Obx(
                              () => CircleAvatar(
                                radius: screenWidth * 0.13,
                                backgroundColor: AppColors.primarySurface,
                                backgroundImage:
                                    controller.isUploadingPhoto.value
                                    ? null
                                    : (p.profilePicture != null
                                          ? NetworkImage(p.profilePicture!)
                                          : null),
                                child: controller.isUploadingPhoto.value
                                    ? const CircularProgressIndicator(
                                        color: AppColors.primary,
                                        strokeWidth: 2,
                                      )
                                    : (p.profilePicture == null
                                          ? Icon(
                                              Icons.person_rounded,
                                              size: screenWidth * 0.13,
                                              color: AppColors.primary,
                                            )
                                          : null),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.016),
                      Text(
                        p.name,
                        style: AppTextStyles.headingLarge.copyWith(
                          fontSize: screenHeight * 0.026,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        p.email,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: screenHeight * 0.017,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.004),
                      Text(
                        '+91 ${p.phoneNumber}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: screenHeight * 0.017,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.016),

                      // Edit profile button inside card
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            controller.prepareEditControllers();
                            Get.to(
                              () => const EditProfilePage(),
                              transition: Transition.cupertino,
                            );
                          },
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            'Edit Profile',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.012),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.018),

                // ── Vehicle details ─────────────────────────────────────────
                _ProfileCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        icon: Icons.directions_car_outlined,
                        label: 'Vehicle Details',
                      ),
                      const _Divider(),
                      _DetailRow(
                        'Vehicle Number',
                        p.vehicleNumber,
                        screenHeight,
                      ),
                      _DetailRow('Vehicle Model', p.vehicleModel, screenHeight),
                      _DetailRow('Owner Name', p.vehicleOwner, screenHeight),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.018),

                // ── Bank details ────────────────────────────────────────────
                _ProfileCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        icon: Icons.account_balance_outlined,
                        label: 'Bank Details',
                      ),
                      const _Divider(),
                      _DetailRow(
                        'Account Number',
                        p.accountNumber,
                        screenHeight,
                      ),
                      _DetailRow('Bank Name', p.bankName, screenHeight),
                      _DetailRow('Branch Name', p.branchName, screenHeight),
                      _DetailRow('IFSC Code', p.ifscCode, screenHeight),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.018),

                // ── Settings ────────────────────────────────────────────────
                _ProfileCard(
                  child: Column(
                    children: [
                      _SettingsRow(
                        icon: Icons.lock_outline_rounded,
                        label: 'Change Password',
                        screenHeight: screenHeight,
                        onTap: () {
                          controller.preparePasswordControllers();
                          Get.to(
                            () => const ChangePasswordPage(),
                            transition: Transition.cupertino,
                          );
                        },
                      ),
                      const _Divider(),
                      _SettingsRow(
                        icon: Icons.delete_outline_rounded,
                        label: 'Delete Account',
                        screenHeight: screenHeight,
                        isDestructive: true,
                        onTap: () => _confirmDeleteAccount(context),
                      ),
                      const _Divider(),
                      _SettingsRow(
                        icon: Icons.logout_rounded,
                        label: 'Logout',
                        screenHeight: screenHeight,
                        onTap: () => _confirmLogout(context),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Avatar source picker ──────────────────────────────────────────────────
  void _showAvatarOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
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
            const SizedBox(height: 20),
            Text('Update Profile Photo', style: AppTextStyles.headingMedium),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _PhotoSourceButton(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    onTap: () {
                      Get.back();
                      controller.pickAndUploadProfilePicture(fromCamera: true);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _PhotoSourceButton(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    onTap: () {
                      Get.back();
                      controller.pickAndUploadProfilePicture(fromCamera: false);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.divider),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Text('Sign out?', style: AppTextStyles.headingSmall),
              const SizedBox(height: 6),
              Text(
                'You can sign back in anytime.',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: controller.isLoggingOut.value
                            ? null
                            : () => Get.back(),
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: AppColors.divider),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: controller.isLoggingOut.value
                            ? null
                            : () {
                                controller.logout();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: controller.isLoggingOut.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Sign out',
                                style: AppTextStyles.buttonSmall,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.statusCancelledSurface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.statusCancelled.withOpacity(0.2),
                  ),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: AppColors.statusCancelled,
                ),
              ),
              const SizedBox(height: 12),
              Text('Delete account?', style: AppTextStyles.headingSmall),
              const SizedBox(height: 6),
              Text(
                'This permanently removes your profile, vehicle info, bank details, and order history. This cannot be undone.',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: AppColors.divider),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        'Keep account',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isDeletingAccount.value
                            ? null
                            : () {
                                Get.back();
                                controller.deleteAccount();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.statusCancelled,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: controller.isDeletingAccount.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text('Delete', style: AppTextStyles.buttonSmall),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  PRIVATE WIDGETS
// ════════════════════════════════════════════════════════════════════════════

class _ProfileCard extends StatelessWidget {
  final Widget child;
  const _ProfileCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      boxShadow: AppShadows.card,
    ),
    padding: AppDimens.cardPadding,
    child: child,
  );
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Icon(icon, size: AppDimens.iconMd, color: AppColors.textPrimary),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.headingSmall),
      ],
    ),
  );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final double screenHeight;
  const _DetailRow(this.label, this.value, this.screenHeight);

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.011),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    ),
  );
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double screenHeight;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.screenHeight,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.012),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppDimens.iconMd,
            color: isDestructive
                ? AppColors.statusCancelled
                : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                color: isDestructive
                    ? AppColors.statusCancelled
                    : AppColors.textPrimary,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: AppDimens.iconMd,
            color: isDestructive
                ? AppColors.statusCancelled
                : AppColors.textSecondary,
          ),
        ],
      ),
    ),
  );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      const Divider(color: AppColors.divider, thickness: 1, height: 1);
}

class _PhotoSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PhotoSourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    ),
  );
}
