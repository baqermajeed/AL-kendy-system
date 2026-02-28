import 'package:reception_app_kendy/core/network/api_constants.dart';

class ImageUtils {
  static bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  static String? convertToValidUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    if (imagePath.startsWith('r2-disabled://')) {
      final path = imagePath.replaceFirst('r2-disabled://', '');
      return '${ApiConstants.baseUrl}/media/$path';
    }
    if (!imagePath.startsWith('/')) {
      return '${ApiConstants.baseUrl}/media/$imagePath';
    }
    return '${ApiConstants.baseUrl}$imagePath';
  }
}
