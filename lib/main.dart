import 'package:axa_driver/core/services/fcm_services.dart';
import 'package:axa_driver/core/services/location_service.dart';
import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:axa_driver/core/services/routers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // ── Firebase init ──────────────────────────────────────────────────────────
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('[Main] Firebase init failed: $e');
  }

  // ── FCM init ───────────────────────────────────────────────────────────────
  // try {
  //   await FcmService.instance.init();
  // } catch (e) {
  //   print('[Main] FCM init failed: $e');
  // }

  // ── Location service init ──────────────────────────────────────────────────
  try {
    await initLocationService();
  } catch (e) {
    print('[Main] Location service init failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AXA Driver',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}