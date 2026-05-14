import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/business_profile.dart';
import 'firestore_rest.dart';

/// Singleton-document service for `settings/businessProfile`.
///
/// Reads go through REST (Windows C++ SDK crashes on `.get()`), writes use
/// the SDK with plain `set(merge:true)`.
///
/// Exposes a [profile] ValueNotifier so any widget that listens (e.g. the
/// app header) auto-rebuilds when the profile is updated anywhere in the app.
class BusinessProfileService {
  BusinessProfileService({FirebaseFirestore? db, FirestoreRest? rest})
      : _db = db ?? FirebaseFirestore.instance,
        _rest = rest;

  final FirebaseFirestore _db;
  FirestoreRest? _rest;

  set rest(FirestoreRest r) => _rest = r;
  FirestoreRest get _restClient => _rest ??= FirestoreRest();

  static const _path = 'settings';
  static const _docId = 'businessProfile';

  /// Global, live profile. Listen to this to react to updates across screens.
  final ValueNotifier<BusinessProfile> profile =
      ValueNotifier<BusinessProfile>(const BusinessProfile());

  bool _loaded = false;
  bool get isLoaded => _loaded;

  /// Reads the profile doc via REST. Falls back to the default profile when
  /// the doc doesn't exist yet. Updates [profile] on success.
  Future<BusinessProfile> fetchSafe() async {
    debugPrint('[BizProfile] fetchSafe: GET /$_path/$_docId via REST...');
    final doc = await _restClient.getDoc(_path, _docId);
    final result = doc == null
        ? const BusinessProfile()
        : BusinessProfile.fromMap(doc.data);
    profile.value = result;
    _loaded = true;
    debugPrint('[BizProfile] fetchSafe: loaded "${result.businessName}"');
    return result;
  }

  /// Saves the profile via the SDK (plain set + merge for Windows safety).
  /// Updates [profile] immediately on success so listeners reflect the new
  /// state without an extra read.
  Future<void> save(BusinessProfile p) async {
    debugPrint('[BizProfile] save: writing /$_path/$_docId...');
    await _db
        .collection(_path)
        .doc(_docId)
        .set(p.toMap(), SetOptions(merge: true));
    profile.value = p;
    _loaded = true;
    debugPrint('[BizProfile] save: write OK');
  }
}
