import 'package:cloud_firestore/cloud_firestore.dart';

class DentalRecordModel {
  final String id;
  final String patientId;
  final String procedure;
  final String? teethAffected;
  final String? findings;
  final String? treatment;
  final DateTime datePerformed;
  final String? dentist;
  final String? notes;
  final DateTime createdAt;
  final String createdBy;

  DentalRecordModel({
    required this.id,
    required this.patientId,
    required this.procedure,
    this.teethAffected,
    this.findings,
    this.treatment,
    required this.datePerformed,
    this.dentist,
    this.notes,
    DateTime? createdAt,
    this.createdBy = '',
  }) : createdAt = createdAt ?? DateTime.now();

  factory DentalRecordModel.fromMap(Map<String, dynamic> map, String id) {
    return DentalRecordModel(
      id: id,
      patientId: map['patientId'] ?? '',
      procedure: map['procedure'] ?? '',
      teethAffected: map['teethAffected'],
      findings: map['findings'],
      treatment: map['treatment'],
      datePerformed: (map['datePerformed'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dentist: map['dentist'],
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      createdBy: map['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'patientId': patientId,
        'procedure': procedure,
        'teethAffected': teethAffected,
        'findings': findings,
        'treatment': treatment,
        'datePerformed': Timestamp.fromDate(datePerformed),
        'dentist': dentist,
        'notes': notes,
        'createdAt': Timestamp.fromDate(createdAt),
        'createdBy': createdBy,
      };
}
