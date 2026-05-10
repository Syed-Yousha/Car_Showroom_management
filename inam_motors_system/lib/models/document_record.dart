import 'package:cloud_firestore/cloud_firestore.dart';
import 'base.dart';

/// Per-document handover state.
/// status: 'inOffice' | 'handedOver' | 'notReceived' | 'notAvailable'
class DocItemState {
  final String status;
  final String? to;
  final String? phone;
  final DateTime? date;

  const DocItemState({
    required this.status,
    this.to,
    this.phone,
    this.date,
  });

  factory DocItemState.fromMap(Map<String, dynamic>? m) {
    if (m == null) return const DocItemState(status: 'inOffice');
    return DocItemState(
      status: asString(m['status'], 'inOffice'),
      to: m['to'] as String?,
      phone: m['phone'] as String?,
      date: tsToDate(m['date']),
    );
  }

  Map<String, dynamic> toMap() => {
        'status': status,
        'to': to,
        'phone': phone,
        'date': dateToTs(date),
      };

  DocItemState copyWith({
    String? status,
    String? to,
    String? phone,
    DateTime? date,
  }) =>
      DocItemState(
        status: status ?? this.status,
        to: to ?? this.to,
        phone: phone ?? this.phone,
        date: date ?? this.date,
      );
}

/// Document tracking record. One per car.
class DocumentRecord {
  final String id;
  final String? carId; // Reference to cars/{carId}
  final String carName;
  final int year;
  final String regNo;
  final String chassisNo;
  final String engineNo;
  final String carStatus;
  final String? buyer;
  final String? buyerPhone;
  final String? regName;
  final String? carColor;
  final String extraNotes;
  final DocItemState file;
  final DocItemState smartCard;
  final DocItemState plate;
  final DocItemState remoteKey;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DocumentRecord({
    required this.id,
    this.carId,
    required this.carName,
    required this.year,
    required this.regNo,
    required this.chassisNo,
    required this.engineNo,
    required this.carStatus,
    this.buyer,
    this.buyerPhone,
    this.regName,
    this.carColor,
    this.extraNotes = '',
    required this.file,
    required this.smartCard,
    required this.plate,
    required this.remoteKey,
    this.createdAt,
    this.updatedAt,
  });

  factory DocumentRecord.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> s) =>
      DocumentRecord.fromMap(s.id, s.data() ?? {});

  factory DocumentRecord.fromMap(String id, Map<String, dynamic> m) {
    return DocumentRecord(
      id: id,
      carId: m['carId'] as String?,
      carName: asString(m['carName']),
      year: asInt(m['year']),
      regNo: asString(m['regNo']),
      chassisNo: asString(m['chassisNo']),
      engineNo: asString(m['engineNo']),
      carStatus: asString(m['carStatus'], 'Available'),
      buyer: m['buyer'] as String?,
      buyerPhone: m['buyerPhone'] as String?,
      regName: m['regName'] as String?,
      carColor: m['carColor'] as String?,
      extraNotes: asString(m['extraNotes']),
      file: DocItemState.fromMap(m['file'] as Map<String, dynamic>?),
      smartCard:
          DocItemState.fromMap(m['smartCard'] as Map<String, dynamic>?),
      plate: DocItemState.fromMap(m['plate'] as Map<String, dynamic>?),
      remoteKey:
          DocItemState.fromMap(m['remoteKey'] as Map<String, dynamic>?),
      createdAt: tsToDate(m['createdAt']),
      updatedAt: tsToDate(m['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'carId': carId,
        'carName': carName,
        'year': year,
        'regNo': regNo,
        'chassisNo': chassisNo,
        'engineNo': engineNo,
        'carStatus': carStatus,
        'buyer': buyer,
        'buyerPhone': buyerPhone,
        'regName': regName,
        'carColor': carColor,
        'extraNotes': extraNotes,
        'file': file.toMap(),
        'smartCard': smartCard.toMap(),
        'plate': plate.toMap(),
        'remoteKey': remoteKey.toMap(),
        'createdAt': dateToTs(createdAt) ?? FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  DocumentRecord copyWith({
    String? carId,
    String? carName,
    int? year,
    String? regNo,
    String? chassisNo,
    String? engineNo,
    String? carStatus,
    String? buyer,
    String? buyerPhone,
    String? regName,
    String? carColor,
    String? extraNotes,
    DocItemState? file,
    DocItemState? smartCard,
    DocItemState? plate,
    DocItemState? remoteKey,
  }) =>
      DocumentRecord(
        id: id,
        carId: carId ?? this.carId,
        carName: carName ?? this.carName,
        year: year ?? this.year,
        regNo: regNo ?? this.regNo,
        chassisNo: chassisNo ?? this.chassisNo,
        engineNo: engineNo ?? this.engineNo,
        carStatus: carStatus ?? this.carStatus,
        buyer: buyer ?? this.buyer,
        buyerPhone: buyerPhone ?? this.buyerPhone,
        regName: regName ?? this.regName,
        carColor: carColor ?? this.carColor,
        extraNotes: extraNotes ?? this.extraNotes,
        file: file ?? this.file,
        smartCard: smartCard ?? this.smartCard,
        plate: plate ?? this.plate,
        remoteKey: remoteKey ?? this.remoteKey,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
