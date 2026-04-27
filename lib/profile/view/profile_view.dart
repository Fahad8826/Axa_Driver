import 'package:axa_driver/core/utils/image_utils.dart';
import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:axa_driver/core/theme/utils/app_erro_widget.dart';
import 'package:axa_driver/profile/controller/profile_controller.dart';
import 'package:axa_driver/profile/model/profile_model.dart';
import 'package:axa_driver/profile/utils/shimmer.dart';
import 'package:axa_driver/profile/view/change_password.dart';
import 'package:axa_driver/profile/view/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textPrimary),
            onPressed: () {
              _confirmLogout(context);
            },
          ),
        ],
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
          return Center(
            child: GestureDetector(
              onTap: controller.fetchProfile,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
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
                                          ? NetworkImage(ImageUtils.getFullUrl(p.profilePicture) ?? '')
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
                              borderRadius: BorderRadius.circular(20),
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
                      _SectionHeader(icon: Icons.settings, label: 'Settings'),
                      const _Divider(),
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
                      // const _Divider(),
                      _SettingsRow(
                        icon: Icons.delete_outline_rounded,
                        label: 'Delete Account',
                        screenHeight: screenHeight,
                        isDestructive: true,
                        onTap: () => _confirmDeleteAccount(context),
                      ),
                      const _Divider(),
                      _SettingsRow(
                        icon: Icons.policy,
                        label: 'Privacy Policy',
                        screenHeight: screenHeight,
                        onTap: () => _openPrivacyPolicy(),
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
      barrierDismissible: false,
      builder: (dialogContext) {
        return Obx(
          () => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: controller.isLoggingOut.value
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
                        // ── Title ──
                        Text('Sign out?', style: AppTextStyles.headingSmall),
                        const SizedBox(height: 8),

                        // ── Body ──
                        Text(
                          'You can sign back in anytime.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Actions ──
                        Row(
                          children: [
                            // Cancel — outlined
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

                            // Sign out — filled primary
                            Expanded(
                              child: SizedBox(
                                height: 38,
                                child: ElevatedButton(
                                  onPressed: () => controller.logout(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.white,
                                    elevation: 0,
                                    shape: const StadiumBorder(),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Sign out',
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

  void _confirmDeleteAccount(BuildContext context) {
    final confirmText = ''.obs;

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
              child: controller.isDeletingAccount.value
                  ? const SizedBox(
                      height: 80,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.statusCancelled,
                        ),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Title ──
                        Text(
                          'Delete account?',
                          style: AppTextStyles.headingSmall,
                        ),
                        const SizedBox(height: 8),

                        // ── Body ──
                        Text(
                          'This permanently removes your profile, vehicle info, bank details, and order history. This cannot be undone.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Confirm input ──
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.statusCancelledSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.statusCancelled.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Text(
                                'Type DELETE to confirm',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.statusCancelled,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                onChanged: (v) => confirmText.value = v.trim(),
                                style: AppTextStyles.bodyMedium,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintText: 'DELETE',
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Actions ──
                        Row(
                          children: [
                            // Keep account — outlined
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

                            // Delete — filled red, enabled only when typed
                            Expanded(
                              child: SizedBox(
                                height: 38,
                                child: ElevatedButton(
                                  onPressed: confirmText.value == 'DELETE'
                                      ? () async {
                                          Navigator.of(dialogContext).pop();
                                          controller.deleteAccount();
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.statusCancelled,
                                    foregroundColor: AppColors.white,
                                    disabledBackgroundColor: AppColors
                                        .statusCancelled
                                        .withOpacity(0.3),
                                    disabledForegroundColor: AppColors.white
                                        .withOpacity(0.6),
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

Future<void> _openPrivacyPolicy() async {
  final Uri url = Uri.parse(
    'https://www.freeprivacypolicy.com/live/b5d5ce9a-03fa-4b04-b230-443e1be2847e',
  );

  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw 'Could not launch $url';
  }
}
