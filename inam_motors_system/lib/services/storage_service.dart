import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Uploads car photos to Firebase Storage and returns the public download URLs.
///
/// Inputs are local Windows file paths from FilePicker (or http(s) URLs that
/// were previously uploaded — those are passed through untouched).
class StorageService {
  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  bool _isRemote(String path) =>
      path.startsWith('http://') || path.startsWith('https://');

  /// Uploads any local paths in [paths]; passes through any existing remote
  /// URLs. Returns the final list of URLs in the same order.
  Future<List<String>> uploadCarPhotos(
    List<String> paths, {
    required String carId,
  }) async {
    final result = <String>[];
    for (final path in paths) {
      if (_isRemote(path)) {
        result.add(path);
        continue;
      }
      try {
        final file = File(path);
        if (!await file.exists()) continue;
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${path.split(RegExp(r"[\\/]")).last}';
        final ref = _storage.ref('cars/$carId/$fileName');
        final task = await ref.putFile(file);
        final url = await task.ref.getDownloadURL();
        result.add(url);
      } catch (e) {
        debugPrint('[StorageService] Upload failed for $path: $e');
      }
    }
    return result;
  }
}
