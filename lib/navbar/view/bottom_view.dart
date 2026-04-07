



import 'package:axa_driver/Home/views/home_view.dart';
import 'package:axa_driver/core/theme/app_icons.dart';
import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:axa_driver/navbar/controller/bottomnav_controller.dart';
import 'package:axa_driver/profile/view/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class BottomNavPage extends GetView<BottomNavController> {
  const BottomNavPage({super.key});
 
  static const List<Widget> _pages = [
    HomeView(),
SizedBox(),
SizedBox(),
ProfileView()
  ];
 
  @override
  Widget build(BuildContext context) {
    Get.put(BottomNavController());
 
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Obx(
          () => IndexedStack(
            index: controller.selectedIndex.value,
            children: _pages,
          ),
        ),
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }
 
  Widget _buildBottomNav(BuildContext context) {
    final double screenWidth  = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
 
    // Responsive nav height: ~9% of screen height, min 60, max 75
    final double navHeight = (screenHeight * 0.09).clamp(60.0, 75.0);
 
    // Icon size responsive to screen width
    final double iconSize = (screenWidth * 0.062).clamp(22.0, 28.0);
 
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          // ── Rounded top-left & top-right corners ─────────────────────
          borderRadius: const BorderRadius.only(
            topLeft:  Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.09),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: navHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(
                  context:   context,
                  index:     0,
                  iconPath:  AppIcons.home,
                  iconSize:  iconSize,
                ),
                _navItem(
                  context:   context,
                  index:     1,
                  iconPath:  AppIcons.delevery,
                  iconSize:  iconSize,
                ),
                _navItem(
                  context:   context,
                  index:     2,
                  iconPath:  AppIcons.notitficaion,
                  iconSize:  iconSize,
                ),
                _navItem(
                  context:   context,
                  index:     3,
                  iconPath:  AppIcons.profile,
                  iconSize:  iconSize,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
 
  Widget _navItem({
    required BuildContext context,
    required int index,
    required String iconPath,
    required double iconSize,
  }) {
    final bool isSelected = controller.selectedIndex.value == index;
    final double screenWidth = MediaQuery.of(context).size.width;
 
    return GestureDetector(
      onTap: () => controller.onNavTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: screenWidth * 0.22, // each item = ~22% of screen width
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── SVG Icon ───────────────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: SvgPicture.asset(
                iconPath,
                key: ValueKey(isSelected),
                width:  iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(
                  isSelected ? AppColors.primary : AppColors.textHint,
                  BlendMode.srcIn,
                ),
              ),
            ),
 
            const SizedBox(height: 5),
 
            // ── Blue dot indicator ─────────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width:  isSelected ? 6 : 0,
              height: isSelected ? 6 : 0,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}