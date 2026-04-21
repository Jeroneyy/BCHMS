import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class FamilyPlanningModel {
  final String id;
  final String patientId;
  final FPMethod method;
  final DateTime dateStarted;
  final DateTime? nextVisit;
  final String? sideEffects;
  final FPStatus status;
  final String? provider;
  final String? notes;
  final DateTime createdAt;
  final String createdBy;

  FamilyPlanningModel({
    required this.id,
    required this.patientId,
    required this.method,
    required this.dateStarted,
    this.nextVisit,
    this.sideEffects,
    this.status = FPStatus.active,
    this.provider,
    this.notes,
    DateTime? createdAt,
    this.createdBy = '',
  }) : createdAt = createdAt ?? DateTime.now();

  factory FamilyPlanningModel.fromMap(Map<String, dynamic> map, String id) {
    return FamilyPlanningModel(
      id: id,
      patientId: map['patientId'] ?? '',
      method: FPMethod.values.firstWhere(
        (m) => m.name == map['method'],
        orElse: () => FPMethod.pills,
      ),
      dateStarted:
          (map['dateStarted'] as Timestamp?)?.toDate() ?? DateTime.now(),
      nextVisit: (map['nextVisit'] as Timestamp?)?.toDate(),
      sideEffects: map['sideEffects'],
      status: FPStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => FPStatus.active,
      ),
      provider: map['provider'],
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      createdBy: map['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'patientId': patientId,
        'method': method.name,
        'dateStarted': Timestamp.fromDate(dateStarted),
        'nextVisit': nextVisit != null ? Timestamp.fromDate(nextVisit!) : null,
        'sideEffects': sideEffects,
        'status': status.name,
        'provider': provider,
        'notes': notes,
        'createdAt': Timestamp.fromDate(createdAt),
        'createdBy': createdBy,
      };
}
