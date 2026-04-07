
import 'package:dio/dio.dart';

class AppError {
  final String title;
  final String message;
  final AppErrorType type;
  final int? statusCode;
  final Map<String, dynamic>? fieldErrors;

  const AppError({
    required this.title,
    required this.message,
    required this.type,
    this.statusCode,
    this.fieldErrors,
  });

  @override
  String toString() =>
      'AppError(type: $type, statusCode: $statusCode, title: $title, message: $message)';
}

enum AppErrorType {
  serverDown,
  noConnection,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  validationError,
  serverError,
  rateLimited,
  unknown,
}

class AppErrorHandler {
  /// Tries to extract a human-readable message from the response body.
  static String? _extractServerMessage(Response? response) {
    try {
      final data = response?.data;
      if (data == null) return null;

      if (data is Map<String, dynamic>) {
        // Common API message fields
        for (final key in ['message', 'detail', 'error', 'msg', 'description']) {
          if (data[key] is String && (data[key] as String).trim().isNotEmpty) {
            return data[key] as String;
          }
        }

        // Django-style non-field errors: {"non_field_errors": ["..."]}
        final nonField = data['non_field_errors'];
        if (nonField is List && nonField.isNotEmpty) {
          return nonField.first.toString();
        }
      }

      if (data is String && data.trim().isNotEmpty) {
        return data.trim();
      }
    } catch (_) {}
    return null;
  }

  /// Extracts field-level validation errors.
  /// e.g. {"email": ["Enter a valid email."], "password": ["This field is required."]}
  static Map<String, dynamic>? _extractFieldErrors(Response? response) {
    try {
      final data = response?.data;
      if (data is Map<String, dynamic>) {
        final Map<String, dynamic> fields = {};
        for (final entry in data.entries) {
          if (entry.key == 'non_field_errors') continue;
          final val = entry.value;
          if (val is List && val.isNotEmpty) {
            fields[entry.key] = val.first.toString();
          } else if (val is String) {
            fields[entry.key] = val;
          }
        }
        return fields.isNotEmpty ? fields : null;
      }
    } catch (_) {}
    return null;
  }

  static AppError fromDioException(DioException e) {
    final response = e.response;
    final statusCode = response?.statusCode;
    final serverMessage = _extractServerMessage(response);
    final fieldErrors = _extractFieldErrors(response);

    // ── No response at all ──────────────────────────────────────────────────
    if (response == null) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          return const AppError(
            title: "Connection Timed Out",
            message:
                "The server took too long to respond. Check your internet and try again.",
            type: AppErrorType.timeout,
          );
        case DioExceptionType.receiveTimeout:
          return const AppError(
            title: "Response Timed Out",
            message:
                "Connected to the server but it took too long to reply. Try again shortly.",
            type: AppErrorType.timeout,
          );
        case DioExceptionType.sendTimeout:
          return const AppError(
            title: "Request Timed Out",
            message: "Your request couldn't be sent in time. Check your connection.",
            type: AppErrorType.timeout,
          );
        case DioExceptionType.connectionError:
          return const AppError(
            title: "No Internet Connection",
            message:
                "Couldn't reach the server. Make sure you're connected to the internet.",
            type: AppErrorType.noConnection,
          );
        default:
          return AppError(
            title: "Server Unreachable",
            message: e.message?.isNotEmpty == true
                ? e.message!
                : "We couldn't connect to the server. Please try again.",
            type: AppErrorType.serverDown,
          );
      }
    }

    // ── Has response ────────────────────────────────────────────────────────
    switch (statusCode) {
      case 400:
        return AppError(
          title: "Invalid Request",
          message: serverMessage ??
              (fieldErrors != null
                  ? "Please fix the errors in the form."
                  : "The information provided is incorrect. Please check and try again."),
          type: AppErrorType.validationError,
          statusCode: statusCode,
          fieldErrors: fieldErrors,
        );

      case 401:
        return AppError(
          title: "Authentication Failed",
          message: serverMessage ??
              "Your credentials are incorrect or your session has expired. Please log in again.",
          type: AppErrorType.unauthorized,
          statusCode: statusCode,
        );

      case 403:
        return AppError(
          title: "Access Denied",
          message: serverMessage ??
              "You don't have permission to perform this action.",
          type: AppErrorType.forbidden,
          statusCode: statusCode,
        );

      case 404:
        return AppError(
          title: "Not Found",
          message: serverMessage ?? "The requested resource could not be found.",
          type: AppErrorType.notFound,
          statusCode: statusCode,
        );

      case 422:
        return AppError(
          title: "Validation Error",
          message: serverMessage ??
              "Some fields are incorrect. Please review your input and try again.",
          type: AppErrorType.validationError,
          statusCode: statusCode,
          fieldErrors: fieldErrors,
        );

      case 429:
        return AppError(
          title: "Too Many Requests",
          message: serverMessage ??
              "You've made too many requests. Please wait a moment and try again.",
          type: AppErrorType.rateLimited,
          statusCode: statusCode,
        );

      case 500:
        return AppError(
          title: "Internal Server Error",
          message: serverMessage ??
              "Something went wrong on our end. Our team has been notified.",
          type: AppErrorType.serverError,
          statusCode: statusCode,
        );

      case 502:
        return const AppError(
          title: "Bad Gateway",
          message: "The server received an invalid response. Please try again later.",
          type: AppErrorType.serverError,
          statusCode: 502,
        );

      case 503:
        return const AppError(
          title: "Service Unavailable",
          message: "The server is temporarily unavailable. Please try again later.",
          type: AppErrorType.serverError,
          statusCode: 503,
        );

      case 504:
        return const AppError(
          title: "Gateway Timeout",
          message: "The server didn't respond in time. Please try again.",
          type: AppErrorType.timeout,
          statusCode: 504,
        );

      default:
        return AppError(
          title: "Something Went Wrong",
          message: serverMessage ?? "An unexpected error occurred (code: $statusCode). Please try again.",
          type: AppErrorType.unknown,
          statusCode: statusCode,
        );
    }
  }

  static AppError generic() {
    return const AppError(
      title: "Something Went Wrong",
      message: "An unexpected error occurred. Please try again.",
      type: AppErrorType.unknown,
    );
  }
}