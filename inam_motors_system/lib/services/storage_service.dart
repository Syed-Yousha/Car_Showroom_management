import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Stores car photos in an app-local cache folder so they survive across
/// sessions without depending on Firebase Storage. Each picked path is
/// copied into `<AppDocuments>\InamMotors_CarPhotos\<carId>\` and the new
/// local path is returned. Paths that already live inside the cache (or
/// any other persistent local location) are passed through unchanged.
class StorageService {
  bool _isCached(String path) =>
      path.contains('InamMotors_CarPhotos') ||
      path.startsWith('http://') ||
      path.startsWith('https://');

  Future<Directory> _cacheDirFor(String carId) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}\\InamMotors_CarPhotos\\$carId');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Copies any newly-picked paths into the local cache and returns the
  /// final list. Paths in the same order as the input. Failures are logged
  /// and the original path is preserved so the UI still has something to
  /// show.
  Future<List<String>> uploadCarPhotos(
    List<String> paths, {
    required String carId,
  }) async {
    if (paths.isEmpty) return const [];
    final dir = await _cacheDirFor(carId);
    final result = <String>[];
    for (final path in paths) {
      if (_isCached(path)) {
        result.add(path);
        continue;
      }
      try {
        final source = File(path);
        if (!await source.exists()) continue;
        final name =
            '${DateTime.now().millisecondsSinceEpoch}_${path.split(RegExp(r"[\\/]")).last}';
        final dest = File('${dir.path}\\$name');
        await source.copy(dest.path);
        result.add(dest.path);
      } catch (e) {
        debugPrint('[StorageService] Cache copy failed for $path: $e');
        result.add(path);
      }
    }
    return result;
  }
}
