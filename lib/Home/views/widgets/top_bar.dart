import 'package:axa_driver/core/theme/app_icons.dart';
import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:axa_driver/core/theme/utils/snackbars.dart';
import 'package:axa_driver/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  child: Row(
    children: [
      Obx(() {
        final pic = controller.profile.value?.profilePicture;
        return CircleAvatar(
          radius: 18,                          // was avatarLg/2 (~22)
          backgroundColor: AppColors.primarySurface,
          backgroundImage: pic != null ? NetworkImage(pic) : null,
          child: pic == null
              ? SvgPicture.asset(
                  AppIcons.profile,
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                )
              : null,
        );
      }),

      const SizedBox(width: 10),

      Expanded(
        child: Obx(() {
          final name = controller.profile.value?.name ?? '...';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting, style: AppTextStyles.greeting),
              Text(name, style: AppTextStyles.greetingName),
            ],
          );
        }),
      ),

      GestureDetector(
        onTap: () => AppFeedback.warning('Notifications coming soon!'),
        child: Container(
          width: 34,                           // was 40
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: AppShadows.card,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.notifications_none,
                  size: 18, color: AppColors.textPrimary),
              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
);
  }
}