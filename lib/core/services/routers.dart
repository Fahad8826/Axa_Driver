import 'package:axa_driver/Home/controller/home_controller.dart';
import 'package:axa_driver/Home/views/home_view.dart';
import 'package:axa_driver/auth/controller/auth_controller.dart';
import 'package:axa_driver/auth/view/login_view.dart';
import 'package:axa_driver/navbar/controller/bottomnav_controller.dart';
import 'package:axa_driver/navbar/view/bottom_view.dart';
import 'package:axa_driver/Onboarding/onboarding.dart';
import 'package:axa_driver/navigation/controller/navigation_controller.dart';
import 'package:axa_driver/orders/controller/orders_controller.dart';
import 'package:axa_driver/profile/controller/profile_controller.dart';
import 'package:axa_driver/splash.dart';
import 'package:axa_driver/navigation/view/navigation_view.dart';
import 'package:get/get.dart';

import '../../scanner/controller/scanner_controller.dart';
import '../../scanner/view/scanner_view.dart';
import 'package:axa_driver/leave/controller/leave_controller.dart';
import 'package:axa_driver/leave/view/leave_list_view.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final pages = [
    GetPage(
      name: AppRoutes.navbar,
      page: () => const BottomNavPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<BottomNavController>(
          () => BottomNavController(),
          fenix: true,
        );

        Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
        Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
        Get.lazyPut<OrdersController>(() => OrdersController(), fenix: true);
      }),
    ),
    GetPage(name: AppRoutes.splash, page: () => const SplashView()),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() => Get.put(AuthController())),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.navigation,
      page: () => const NavigationView(),
      transition: Transition.rightToLeft,
      binding: BindingsBuilder(() {
        Get.put<NavigationController>(NavigationController());
      }),
    ),
    GetPage(
      name: AppRoutes.scanner,
      page: () => const ScannerView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ScannerController>(() => ScannerController());
      }),
    ),
    GetPage(
      name: AppRoutes.leave,
      page: () => const LeaveListView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LeaveController>(() => LeaveController());
      }),
      transition: Transition.rightToLeft,
    ),
  ];
}

abstract class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const home = '/home';
  static const navbar = '/navbar';
  static const navigation = '/navigation';
  static const scanner = '/scanner';
  static const leave = '/leave';
}
