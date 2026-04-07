import 'package:axa_driver/core/services/app_pref.dart';
import 'package:axa_driver/core/services/routers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';


class DioClient {
  DioClient._();

  static Dio? _instance;

  static Dio get dio {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final baseUrl = dotenv.env['BASE_URL'] ?? '';

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(_AuthInterceptor());
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: false,
      responseHeader: false,
    ));

    return dio;
  }
}

// Reads token from FlutterSecureStorage (via AppPrefs) on every request
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await AppPrefs.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 ||
        err.response?.statusCode == 403) {
      await AppPrefs.clear();
      Get.offAllNamed(AppRoutes.login);
      return; // Don't call handler.next() — navigation already handled
    }
    handler.next(err);
  }
}