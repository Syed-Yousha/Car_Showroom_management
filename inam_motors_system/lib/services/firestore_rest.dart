import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

/// Read-only Firestore client that talks to the Firestore REST API instead
/// of going through the `cloud_firestore` plugin.
///
/// Why: on Windows the `cloud_firestore` C++ SDK crashes the Dart VM on
/// every `.get()` and `.snapshots()` call. Writes still go through the
/// SDK (those work). For reads we use HTTPS + the user's Firebase Auth
/// ID token, which is rock-solid on every platform.
class FirestoreRest {
  FirestoreRest({
    String? projectId,
    String databaseId = '(default)',
    http.Client? httpClient,
  })  : _projectId = projectId ?? Firebase.app().options.projectId,
        _databaseId = databaseId,
        _http = httpClient ?? http.Client();

  final String _projectId;
  final String _databaseId;
  final http.Client _http;

  String get _base =>
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/$_databaseId/documents';

  Future<String> _token() async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('FirestoreRest: no signed-in user.');
    }
    final t = await user.getIdToken();
    if (t == null || t.isEmpty) {
      throw StateError('FirestoreRest: empty ID token.');
    }
    return t;
  }

  /// List every document in [collection]. Returns a list of `(id, data)`
  /// records where `data` is the unwrapped field map (plain Dart values).
  ///
  /// Pages internally — Firestore returns up to 100 docs per page by
  /// default; we follow `nextPageToken` until exhausted.
  Future<List<RestDoc>> listDocs(String collection) async {
    final token = await _token();
    final results = <RestDoc>[];
    String? pageToken;

    do {
      final qp = pageToken == null ? '' : '?pageToken=${Uri.encodeQueryComponent(pageToken)}';
      final url = Uri.parse('$_base/$collection$qp');
      final res = await _http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode != 200) {
        throw FirestoreRestException(
          method: 'GET',
          url: url.toString(),
          statusCode: res.statusCode,
          body: res.body,
        );
      }
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final docs = (body['documents'] as List?) ?? const [];
      for (final raw in docs) {
        final m = raw as Map<String, dynamic>;
        final name = m['name'] as String;
        final id = name.split('/').last;
        final fields =
            (m['fields'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
        results.add(RestDoc(id: id, data: _unwrapFields(fields)));
      }
      pageToken = body['nextPageToken'] as String?;
    } while (pageToken != null);

    return results;
  }

  /// Get a single document by [collection] + [id]. Returns `null` on 404.
  Future<RestDoc?> getDoc(String collection, String id) async {
    final token = await _token();
    final url = Uri.parse('$_base/$collection/$id');
    final res = await _http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 404) return null;
    if (res.statusCode != 200) {
      throw FirestoreRestException(
        method: 'GET',
        url: url.toString(),
        statusCode: res.statusCode,
        body: res.body,
      );
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final fields =
        (body['fields'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    return RestDoc(id: id, data: _unwrapFields(fields));
  }

  /// Convert Firestore's value-tagged field map into plain Dart values.
  static Map<String, dynamic> _unwrapFields(Map<String, dynamic> fields) {
    final out = <String, dynamic>{};
    fields.forEach((k, v) {
      out[k] = _unwrapValue(v as Map<String, dynamic>);
    });
    return out;
  }

  /// Firestore REST returns each value as a one-key wrapper map like
  /// `{"stringValue": "Faheem"}` or `{"integerValue": "42"}` (yes, ints
  /// arrive as strings). Strip the wrapper.
  static dynamic _unwrapValue(Map<String, dynamic> w) {
    if (w.containsKey('stringValue')) return w['stringValue'];
    if (w.containsKey('integerValue')) {
      final v = w['integerValue'];
      return v is String ? int.parse(v) : v;
    }
    if (w.containsKey('doubleValue')) {
      final v = w['doubleValue'];
      return v is num ? v.toDouble() : double.parse(v.toString());
    }
    if (w.containsKey('booleanValue')) return w['booleanValue'];
    if (w.containsKey('nullValue')) return null;
    if (w.containsKey('timestampValue')) {
      // ISO 8601 string — model helpers (`tsToDate`) already parse strings
      // into DateTime, so we don't need to convert here.
      return w['timestampValue'];
    }
    if (w.containsKey('mapValue')) {
      final mv = w['mapValue'] as Map<String, dynamic>;
      final f = (mv['fields'] as Map<String, dynamic>?) ??
          const <String, dynamic>{};
      return _unwrapFields(f);
    }
    if (w.containsKey('arrayValue')) {
      final av = w['arrayValue'] as Map<String, dynamic>;
      final values = (av['values'] as List?) ?? const [];
      return values
          .map((v) => _unwrapValue(v as Map<String, dynamic>))
          .toList();
    }
    if (w.containsKey('referenceValue')) return w['referenceValue'];
    if (w.containsKey('geoPointValue')) return w['geoPointValue'];
    if (w.containsKey('bytesValue')) return w['bytesValue'];
    return null;
  }
}

/// Plain (id, data) tuple returned by [FirestoreRest].
class RestDoc {
  const RestDoc({required this.id, required this.data});
  final String id;
  final Map<String, dynamic> data;
}

class FirestoreRestException implements Exception {
  FirestoreRestException({
    required this.method,
    required this.url,
    required this.statusCode,
    required this.body,
  });

  final String method;
  final String url;
  final int statusCode;
  final String body;

  @override
  String toString() =>
      'FirestoreRestException($method $url -> $statusCode): $body';
}
