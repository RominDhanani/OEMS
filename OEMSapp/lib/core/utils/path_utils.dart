import '../constants/api_constants.dart';

class PathUtils {
  /// Normalizes an image or document path from the backend and returns a full URL.
  /// Handles double '/uploads/' prefixes and platform-specific backslashes.
  static String normalizeImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    
    // 1. Normalize all slashes to forward slashes first
    String normalizedPath = path.replaceAll('\\', '/');
    
    // 2. Locate the 'uploads/' token in a case-insensitive manner
    final String lowerPath = normalizedPath.toLowerCase();
    const String uploadsToken = 'uploads/';
    final int uploadsIndex = lowerPath.lastIndexOf(uploadsToken);
    
    if (uploadsIndex != -1) {
      // Extract the portion AFTER 'uploads/'
      normalizedPath = normalizedPath.substring(uploadsIndex + uploadsToken.length);
    }
    
    // 3. Clean up the resulting path (leading slashes)
    if (normalizedPath.startsWith('/')) {
      normalizedPath = normalizedPath.substring(1);
    }
    
    // 4. Safely join with storageUrl
    String storageUrl = ApiConstants.storageUrl;
    if (storageUrl.endsWith('/')) {
      storageUrl = storageUrl.substring(0, storageUrl.length - 1);
    }
    
    return "$storageUrl/$normalizedPath";
  }
}
