import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class ImmunizationRecordModel {
  final String id;
  final String patientId;
  final VaccineType vaccineType;
  final String? vaccineName; // custom name if type is "other"
  final int doseNumber;
  final DateTime dateAdministered;
  final DateTime? nextDueDate;
  final String? batchNumber;
  final String? administeredBy;
  final String? remarks;
  final DateTime createdAt;

  ImmunizationRecordModel({
    required this.id,
    required this.patientId,
    required this.vaccineType,
    this.vaccineName,
    this.doseNumber = 1,
    required this.dateAdministered,
    this.nextDueDate,
    this.batchNumber,
    this.administeredBy,
    this.remarks,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get displayName =>
      vaccineType == VaccineType.other
          ? vaccineName ?? 'Other'
          : vaccineType.label;

  factory ImmunizationRecordModel.fromMap(
      Map<String, dynamic> map, String id) {
    return ImmunizationRecordModel(
      id: id,
      patientId: map['patientId'] ?? '',
      vaccineType: VaccineType.values.firstWhere(
        (v) => v.name == map['vaccineType'],
        orElse: () => VaccineType.other,
      ),
      vaccineName: map['vaccineName'],
      doseNumber: map['doseNumber'] ?? 1,
      dateAdministered:
          (map['dateAdministered'] as Timestamp?)?.toDate() ?? DateTime.now(),
      nextDueDate: (map['nextDueDate'] as Timestamp?)?.toDate(),
      batchNumber: map['batchNumber'],
      administeredBy: map['administeredBy'],
      remarks: map['remarks'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'patientId': patientId,
        'vaccineType': vaccineType.name,
        'vaccineName': vaccineName,
        'doseNumber': doseNumber,
        'dateAdministered': Timestamp.fromDate(dateAdministered),
        'nextDueDate':
            nextDueDate != null ? Timestamp.fromDate(nextDueDate!) : null,
        'batchNumber': batchNumber,
        'administeredBy': administeredBy,
        'remarks': remarks,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
