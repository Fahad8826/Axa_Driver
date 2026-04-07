import 'package:axa_driver/core/services/app_pref.dart';
import 'package:axa_driver/core/services/routers.dart';
import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:axa_driver/core/services/location_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  // Logo: fade + gentle scale
  late AnimationController _logoController;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;

  // Shine sweep across the screen
  late AnimationController _shineController;
  late Animation<double> _shineAnim;

  @override
  void initState() {
    super.initState();

    // Pure white status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.white,
      ),
    );

    // ── Logo animation (0 → 600ms) ──────────────────────────────────────
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _logoFade = CurvedAnimation(parent: _logoController, curve: Curves.easeIn);

    _logoScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    // ── Shine sweep animation (starts after logo appears) ───────────────
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _shineAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );

    // Sequence: logo fades in → shine sweeps → navigate
    _logoController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _shineController.forward();
      });
    });

    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1600));

    final onboardingDone = await AppPrefs.isOnboardingDone();
    final isLoggedIn = await AppPrefs.isLoggedIn();
    final accessToken = await AppPrefs.getAccessToken();

    // If flagged as logged in but token is missing → force logout
    if (isLoggedIn && (accessToken == null || accessToken.isEmpty)) {
      await AppPrefs.clear();
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    if (isLoggedIn) {
      await startLocationService();
      Get.offAllNamed(AppRoutes.navbar);
    } else if (onboardingDone) {
      Get.offAllNamed(AppRoutes.login);
    } else {
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // ── Subtle radial glow in center for premium depth ─────────────
          Center(
            child: Container(
              width: size.width * 0.9,
              height: size.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primarySurface.withOpacity(0.45),
                    AppColors.white.withOpacity(0.0),
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),

          // ── Centered logo ──────────────────────────────────────────────
          Center(
            child: ScaleTransition(
              scale: _logoScale,
              child: FadeTransition(
                opacity: _logoFade,
                child: SizedBox(
                  width: size.width * 0.38, // small & premium
                  child: Image.asset(
                    'assets/images/Axa Logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // ── Shine sweep overlay ────────────────────────────────────────
          AnimatedBuilder(
            animation: _shineAnim,
            builder: (_, __) {
              return IgnorePointer(
                child: Transform.translate(
                  offset: Offset(size.width * _shineAnim.value, 0),
                  child: Container(
                    width: size.width * 0.35,
                    height: size.height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.55),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
