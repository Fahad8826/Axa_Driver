import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageUtils {
  static String? getFullUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    
    final baseUrl = dotenv.env['BASE_URL'] ?? '';
    // Ensure no double slashes if both have them, or add one if neither does
    if (baseUrl.endsWith('/') && path.startsWith('/')) {
      return baseUrl + path.substring(1);
    } else if (!baseUrl.endsWith('/') && !path.startsWith('/')) {
      return '$baseUrl/$path';
    }
    return baseUrl + path;
  }
}
