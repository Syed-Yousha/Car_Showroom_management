import 'package:cloud_firestore/cloud_firestore.dart';
import 'base.dart';

/// Singleton business profile document. Lives at `settings/businessProfile`.
class BusinessProfile {
  final String businessName;
  final String ownerName;
  final String phone;
  final String email;
  final String address;
  final String logoUrl;
  final DateTime? updatedAt;

  const BusinessProfile({
    this.businessName = 'Inam Motors',
    this.ownerName = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.logoUrl = '',
    this.updatedAt,
  });

  factory BusinessProfile.fromMap(Map<String, dynamic> m) => BusinessProfile(
        businessName: asString(m['businessName'], 'Inam Motors'),
        ownerName: asString(m['ownerName']),
        phone: asString(m['phone']),
        email: asString(m['email']),
        address: asString(m['address']),
        logoUrl: asString(m['logoUrl']),
        updatedAt: tsToDate(m['updatedAt']),
      );

  Map<String, dynamic> toMap() => {
        'businessName': businessName,
        'ownerName': ownerName,
        'phone': phone,
        'email': email,
        'address': address,
        'logoUrl': logoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  BusinessProfile copyWith({
    String? businessName,
    String? ownerName,
    String? phone,
    String? email,
    String? address,
    String? logoUrl,
  }) =>
      BusinessProfile(
        businessName: businessName ?? this.businessName,
        ownerName: ownerName ?? this.ownerName,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        address: address ?? this.address,
        logoUrl: logoUrl ?? this.logoUrl,
        updatedAt: updatedAt,
      );

  /// The two-letter monogram used as a logo placeholder when no logoUrl is
  /// set. Derived from the business name's word initials.
  String get initials {
    final parts = businessName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'IM';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}
