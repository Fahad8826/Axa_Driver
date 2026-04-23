import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:axa_driver/core/services/app_pref.dart';
import 'package:axa_driver/core/services/routers.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      imagePath: 'assets/images/onboarding1.png',
      title: 'Start Your Deliveries\nwith Confidence',
      subtitle:
          'Log in and begin managing your assigned\nwater deliveries with ease.',
    ),
    _OnboardingData(
      imagePath: 'assets/images/onboarding2.png',
      title: 'Your Deliveries,\nYour Earnings',
      subtitle:
          'Track and grow your earnings by completing\ndeliveries on time.',
    ),
  ];

  Future<void> _onGetStarted() async {
    await AppPrefs.setOnboardingDone();
    Get.offAllNamed(AppRoutes.login);
  }

  void _onButtonTap() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _onGetStarted();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth  = MediaQuery.of(context).size.width;
    final double imageHeight  = screenHeight * 0.62;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // ── 1. Image PageView fills top 62% ───────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: imageHeight,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _pages.length,
              itemBuilder: (_, i) => Image.asset(
                _pages[i].imagePath,
                width: screenWidth,
                height: imageHeight,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          // ── 2. White base for bottom section ──────────────────────────
          Positioned(
            top: imageHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(color: AppColors.white),
          ),

          // ── 3. Gradient fade overlay (image → white) ──────────────────
          Positioned(
            top: imageHeight * 0.68,
            left: 0,
            right: 0,
            height: imageHeight * 0.32 + 1,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.white.withOpacity(0.0),
                      AppColors.white.withOpacity(0.73),
                      AppColors.white,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── 4. Bottom content ─────────────────────────────────────────
          Positioned(
            top: imageHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.022),

                  // ── Dot indicators ─────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentPage == i ? 26 : 8,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? AppColors.primaryDark  // ← AppColors
                              : AppColors.border,      // ← AppColors
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.030),

                  // ── Title ──────────────────────────────────────────────
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: Text(
                      _pages[_currentPage].title,
                      key: ValueKey('title$_currentPage'),
                      textAlign: TextAlign.center,
                      // ↓ AppTextStyles.onboardingTitle + responsive size
                      style: AppTextStyles.onboardingTitle.copyWith(
                        fontSize: screenHeight * 0.031,
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.016),

                  // ── Subtitle ───────────────────────────────────────────
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: Text(
                      _pages[_currentPage].subtitle,
                      key: ValueKey('sub$_currentPage'),
                      textAlign: TextAlign.center,
                      // ↓ AppTextStyles.onboardingSubtitle + responsive size
                      style: AppTextStyles.onboardingSubtitle.copyWith(
                        fontSize: screenHeight * 0.0175,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // ── Button ─────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: screenHeight * 0.063,
                    child: ElevatedButton(
                      onPressed: _onButtonTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,       // ← AppColors
                        foregroundColor: AppColors.textOnPrimary, // ← AppColors
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimens.buttonHeight, // ← AppDimens
                          ),
                        ),
                      ),
                      child: Text(
                        _currentPage < _pages.length - 1
                            ? 'Next'
                            : 'Get Started',
                        // ↓ AppTextStyles.button + responsive size
                        style: AppTextStyles.button.copyWith(
                          fontSize: screenHeight * 0.022,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.042),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────
class _OnboardingData {
  final String imagePath;
  final String title;
  final String subtitle;

  const _OnboardingData({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });
}