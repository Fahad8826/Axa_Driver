
import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ──────────────── WEBSOCKET BASE ──────────────────
String get _wsBase {
  final base = dotenv.env['BASE_URL'];
  if (base == null || base.isEmpty) {
    throw Exception('BASE_URL not found in .env');
  }
  return '${base.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://')}/ws/driver-location/';
}

const int _intervalSeconds = 30;
const String _channelId = 'axa_location_channel';
const int _notifId = 999;

// Prevent concurrent service starts
bool _isStartingService = false;

// ────────────────────────────────────────────────
// INIT — call once in main.dart BEFORE runApp
// ────────────────────────────────────────────────
Future<void> initLocationService() async {
  // 1. Create Android notification channel first
  final FlutterLocalNotificationsPlugin notif = FlutterLocalNotificationsPlugin();

  await notif
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          'Location Tracking',
          description: 'AXA Driver live location tracking',
          importance: Importance.low,
        ),
      );

  // 2. Configure background service
  final service = FlutterBackgroundService();
  try {
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onServiceStart, // ← top-level function, @pragma annotated
        autoStart: false, // Never auto-start to prevent crashes
        isForegroundMode: true,
        notificationChannelId: _channelId,
        initialNotificationTitle: 'AXA Driver',
        initialNotificationContent: 'Preparing location tracking...',
        foregroundServiceNotificationId: _notifId,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false, // Never auto-start to prevent crashes
        onForeground: onServiceStart,
        onBackground: onIosBackground,
      ),
    );
  } catch (e) {
    print('[LocationService] ❌ Service configuration failed: $e');
    // Don't throw, just log - app can still work without background service
  }

  print('[LocationService] ✅ initLocationService done');
}

// ────────────────────────────────────────────────
// iOS BACKGROUND HANDLER
// ────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

// ────────────────────────────────────────────────
// BACKGROUND ISOLATE — top-level + @pragma
// ────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> onServiceStart(ServiceInstance service) async {
  try {
    // WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    // ✅ Load environment variables
    await dotenv.load(fileName: ".env");

    print('[LocationService] 🚀 onServiceStart called');

    // ── Android foreground setup ──────────────
    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((_) => service.setAsForegroundService());
      service.on('setAsBackground').listen((_) => service.setAsBackgroundService());

      await service.setAsForegroundService();
      print('[LocationService] ✅ Set as foreground service');
    }

  // ── Stop signal ──────────────
  service.on('stopService').listen((_) async {
    print('[LocationService] 🛑 Stopping...');
    _wsChannel?.sink.close();
    _wsChannel = null;
    await service.stopSelf();
  });

  // ── Read token ──────────────
  print('[LocationService] 🔑 Reading token...');
  String? token;
  try {
    const storage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
    token = await storage.read(key: 'access_token');
  } catch (e) {
    print('[LocationService] ❌ Token read error: $e');
    print('[LocationService] 🔄 Retrying with basic options...');
    try {
      const storage = FlutterSecureStorage();
      token = await storage.read(key: 'access_token');
    } catch (e2) {
      print('[LocationService] ❌ Token read failed completely: $e2');
      await service.stopSelf();
      return;
    }
  }

  if (token == null || token.isEmpty) {
    print('[LocationService] ❌ No token found — stopping');
    await service.stopSelf();
    return;
  }
  print('[LocationService] ✅ Token OK: ${token.substring(0, 20)}...');

  // ── Check GPS permission ──────────────
  LocationPermission permission;
  try {
    permission = await Geolocator.checkPermission();
    print('[LocationService] 📍 GPS permission: $permission');
  } catch (e) {
    print('[LocationService] ❌ GPS check failed: $e');
    await service.stopSelf();
    return;
  }

  if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    print('[LocationService] ❌ GPS permission denied — stopping');
    await service.stopSelf();
    return;
  }

  // ── Connect WebSocket ──────────────
  try {
    await _connectWs(token);
  } catch (e) {
    print('[LocationService] ❌ WS connection failed: $e');
    // Don't stop service, try to continue with location updates
  }

  // ── Send first location immediately ──────────────
  try {
    await _sendLocation(token, service);
  } catch (e) {
    print('[LocationService] ❌ Initial location send failed: $e');
  }

  // ── Then every 30 seconds ──────────────
  int tick = 0;
  Timer.periodic(const Duration(seconds: _intervalSeconds), (_) async {
    try {
      tick++;
      print('[LocationService] ⏱️ Tick #$tick');
      await _sendLocation(token!, service); // token is guaranteed non-null here
    } catch (e) {
      print('[LocationService] ❌ Periodic location error: $e');
      // Continue the timer even if one location update fails
    }
  });

    print('[LocationService] ✅ Timer started — every ${_intervalSeconds}s');

  } catch (e, stackTrace) {
    print('[LocationService] ❌ CRITICAL ERROR in background service: $e');
    print('[LocationService] Stack trace: $stackTrace');
    await service.stopSelf();
  }
}

// ────────────────────────────────────────────────
// WebSocket
// ────────────────────────────────────────────────
WebSocketChannel? _wsChannel;

Future<void> _connectWs(String token) async {
  if (_wsChannel != null) {
    print('[LocationService] ⚠️ WS already connected');
    return;
  }

  try {
    final uri = Uri.parse('$_wsBase?token=$token');
    print('[LocationService] 🔌 Connecting to: $uri');
    final channel = WebSocketChannel.connect(uri);

    // Add timeout to WebSocket connection
    await channel.ready.timeout(const Duration(seconds: 10));
    print('[LocationService] ✅ WS channel connected');

    _wsChannel = channel;
    _wsChannel!.stream.listen(
      (data) => print('[LocationService] WS ← $data'),
      onError: (e) {
        print('[LocationService] ❌ WS error: $e');
        _wsChannel = null;
      },
      onDone: () async {
        print('[LocationService] ⚠️ WS closed — reconnecting in 3s...');
        _wsChannel = null;
        // Only reconnect if token is still valid
        await Future.delayed(const Duration(seconds: 3));
        try {
          await _connectWs(token);
        } catch (e) {
          print('[LocationService] ❌ WS reconnection failed: $e');
        }
      },
      cancelOnError: false,
    );
  } on TimeoutException {
    print('[LocationService] ❌ WS connection timeout');
    _wsChannel = null;
  } catch (e) {
    print('[LocationService] ❌ WS connect failed: $e');
    _wsChannel = null;
  }
}

// ────────────────────────────────────────────────
// Send location
// ────────────────────────────────────────────────
Future<void> _sendLocation(String token, ServiceInstance service) async {
  try {
    print('[LocationService] 📍 Getting position...');
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    ).timeout(const Duration(seconds: 15));

    print('[LocationService] ✅ Got: ${pos.latitude}, ${pos.longitude}');

    // Try to reconnect WebSocket if needed
    if (_wsChannel == null) {
      print('[LocationService] ⚠️ WS null — reconnecting...');
      try {
        await _connectWs(token);
      } catch (e) {
        print('[LocationService] ❌ WS reconnection failed, continuing without WS: $e');
      }
    }

    final payload = jsonEncode({
      'latitude': pos.latitude.toString(),
      'longitude': pos.longitude.toString(),
    });

    try {
      _wsChannel?.sink.add(payload);
      print('[LocationService] ✅ SENT: $payload');
    } catch (e) {
      print('[LocationService] ❌ WS send failed: $e');
    }

    if (service is AndroidServiceInstance) {
      try {
        service.setForegroundNotificationInfo(
          title: 'AXA Driver — Live',
          content:
              '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}',
        );
      } catch (e) {
        print('[LocationService] ❌ Notification update failed: $e');
      }
    }
  } on TimeoutException {
    print('[LocationService] ❌ GPS timeout - location unavailable');
  } catch (e) {
    print('[LocationService] ❌ sendLocation error: $e');
  }
}

// ────────────────────────────────────────────────
// PUBLIC API
// ────────────────────────────────────────────────
Future<void> startLocationService() async {
  print('[LocationService] 🚀 startLocationService called');

  // Prevent concurrent starts
  if (_isStartingService) {
    print('[LocationService] ⚠️ Service start already in progress');
    return;
  }

  _isStartingService = true;

  try {
    // Ensure we're on the main isolate
    if (!WidgetsBinding.instance.isRootWidgetAttached) {
      print('[LocationService] ❌ Not on main isolate, delaying...');
      await Future.delayed(const Duration(milliseconds: 100));
      if (!WidgetsBinding.instance.isRootWidgetAttached) {
        print('[LocationService] ❌ Still not on main isolate, aborting');
        _isStartingService = false;
        return;
      }
    }

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        print('[LocationService] ❌ Permission denied');
        _isStartingService = false;
        return;
      }
    }
    if (perm == LocationPermission.deniedForever) {
      print('[LocationService] ❌ Permission permanently denied');
      _isStartingService = false;
      return;
    }

    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();
    print('[LocationService] Is already running: $isRunning');

    if (!isRunning) {
      await service.startService();
      print('[LocationService] ✅ Service start requested');
    } else {
      print('[LocationService] ⚠️ Service already running');
    }
  } catch (e) {
    print('[LocationService] ❌ Service start failed: $e');
    print('[LocationService] This might be an isolate issue - service will retry later');
  } finally {
    _isStartingService = false;
  }
}

Future<void> stopLocationService() async {
  FlutterBackgroundService().invoke('stopService');
  print('[LocationService] 🛑 Stop invoked');
}


