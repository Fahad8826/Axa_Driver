import 'dart:io'; // For Platform check
import 'package:axa_driver/core/network/dioclient.dart';
import 'package:axa_driver/core/services/app_pref.dart';
import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:axa_driver/core/theme/utils/appfeedback.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart'; // ← for EdgeInsets
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

// ── Background message handler (MUST be top-level function) ──────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // App is in background or terminated — handle silently
  // No UI interaction possible here
  print('[FCM] Background message: ${message.messageId}');
}

// ═════════════════════════════════════════════════════════════════════════════
//  FCM SERVICE
// ═════════════════════════════════════════════════════════════════════════════
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();
  final dio_pkg.Dio _dio = DioClient.dio;

  // Android notification channel (required for Android 8+)
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'axa_driver_high',
    'AXA Driver Notifications',
    description: 'Delivery and order notifications for AXA Driver',
    importance: Importance.high,
  );

  // ── INIT (call once in main.dart after Firebase.initializeApp) ────────────
  Future<void> init() async {
    // 1. Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 2. Request permission (iOS + Android 13+)
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('[FCM] Notifications permission denied.');
      return;
    }

    // 3. Setup local notifications for foreground display
    await _initLocalNotifications();

    // 4. Get token and send to backend
    await _getAndSendToken();

    // 5. Listen for token refresh (Firebase rotates tokens periodically)
    _fcm.onTokenRefresh.listen((newToken) async {
      print('[FCM] Token refreshed');
      await _sendTokenToBackend(newToken);
    });

    // 6. Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 7. Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    // 8. Handle notification tap when app was terminated
    final initial = await _fcm.getInitialMessage();
    if (initial != null) _handleMessageTap(initial);
  }

  // ── LOCAL NOTIFICATIONS SETUP ─────────────────────────────────────────────
  Future<void> _initLocalNotifications() async {
    await _localNotif
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotif.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        _handleNotificationPayload(details.payload);
      },
    );

    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // ── GET TOKEN & SEND TO BACKEND ───────────────────────────────────────────
  Future<void> _getAndSendToken() async {
    try {
      final token = await _fcm.getToken();
      if (token == null || token.isEmpty) {
        print('[FCM] Token is null or empty — device may not support FCM');
        return;
      }
      print(
        '[FCM] Token obtained (${token.length} chars): ${token.substring(0, 50)}...',
      );
      await _sendTokenToBackend(token);
    } catch (e) {
      print('[FCM] Failed to get token: $e');
      print('[FCM] FCM Error details: ${e.toString()}');
    }
  }

  // ── SEND TOKEN TO BACKEND ─────────────────────────────────────────────────
  Future<void> _sendTokenToBackend(String token) async {
    try {
      // Validate token before sending
      if (token.isEmpty) {
        print('[FCM] Token is empty, skipping send');
        return;
      }

      print('[FCM] Sending token to backend: ${token.substring(0, 50)}...');

      final accessToken = await AppPrefs.getAccessToken();

      // Not logged in yet — save locally, send after login
      if (accessToken == null || accessToken.isEmpty) {
        print('[FCM] No access token, saving locally');
        await AppPrefs.saveFcmToken(token);
        return;
      }

      // Use FormData as per working example
      final formData = dio_pkg.FormData.fromMap({
        'fcm_token': token,
        'device_type': Platform.isAndroid ? 'android' : 'ios',
      });

      final response = await _dio.post(
        '/api/save-fcm-token/', // Updated endpoint
        data: formData,
        options: dio_pkg.Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode == 200) {
        print('[FCM] Token sent to backend successfully');
        await AppPrefs.saveFcmToken(token);
      }
    } on dio_pkg.DioException catch (e) {
      print('[FCM] Failed to send token: ${e.response?.statusCode}');
      print('[FCM] Response data: ${e.response?.data}');
    } catch (e) {
      print('[FCM] Error sending token: $e');
    }
  }

  // ── Call after login to ensure token is registered ────────────────────────
  Future<void> sendSavedTokenAfterLogin() async {
    final savedToken = await AppPrefs.getFcmToken();
    if (savedToken != null && savedToken.isNotEmpty) {
      print('[FCM] Sending saved token after login');
      await _sendTokenToBackend(savedToken);
    } else {
      print('[FCM] No saved token, getting new one');
      await _getAndSendToken();
    }
  }

  // ── FOREGROUND MESSAGE HANDLER ────────────────────────────────────────────
  void _handleForegroundMessage(RemoteMessage message) {
    print('[FCM] Foreground message: ${message.notification?.title}');

    final notification = message.notification;
    if (notification == null) return;

    _localNotif.show(
      message.messageId?.hashCode ?? 0, // positional: id
      notification.title, // positional: title
      notification.body, // positional: body
      NotificationDetails(
        // positional: notificationDetails
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['route'], // payload stays named
    );



    AppFeedback.info(notification.title ?? 'You have a new notification');
  }

  // ── NOTIFICATION TAP HANDLER ──────────────────────────────────────────────
  void _handleMessageTap(RemoteMessage message) {
    print('[FCM] Notification tapped: ${message.data}');
    _handleNotificationPayload(message.data['route']);
  }

  void _handleNotificationPayload(String? route) {
    if (route == null || route.isEmpty) return;
    Get.toNamed(route);
  }
}
