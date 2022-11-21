import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// Image Helper
class ImageHelper {
  ImageHelper._();

  /// get file path from url
  static Future<String?> getFilePathFromUrl(String url) async {
    await preloadImage(url);
    return (await getImageFile(url))?.path;
  }

  /// Pre-cache images by url
  static Future<void> preloadImage(String url) async {
    final ExtendedNetworkImageProvider provider =
        ExtendedNetworkImageProvider(url, cache: true);

    await provider.getNetworkImageData();
  }

  /// Get the cache file by url
  static Future<File?> getImageFile(String? url) async {
    try {
      if (url == null) {
        return null;
      }

      final Directory _cacheImagesDirectory = Directory(
          join((await getTemporaryDirectory()).path, cacheImageFolderName));

      if (!_cacheImagesDirectory.existsSync()) {
        return null;
      }

      final String md5Key = keyToMd5(url);
      final File cacheFlie = File(join(_cacheImagesDirectory.path, md5Key));

      if (cacheFlie.existsSync()) {
        return cacheFlie;
      }
    } catch (e) {
      // error('getImageFile error : $e');
    }

    return null;
  }
}
