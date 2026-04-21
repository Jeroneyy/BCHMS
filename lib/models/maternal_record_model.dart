import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class MaternalRecordModel {
  final String id;
  final String patientId;
  final DateTime lmp; // Last Menstrual Period
  final DateTime edd; // Expected Date of Delivery
  final int gravida;
  final int para;
  final int visitNumber;
  final int? aog; // Age of Gestation in weeks
  final double? fundalHeight;
  final String? fetalHeartTone;
  final String? bloodPressure;
  final double? weight;
  final String? urinalysis;
  final MaternalStatus status;
  final String? notes;
  final DateTime createdAt;
  final String createdBy;

  MaternalRecordModel({
    required this.id,
    required this.patientId,
    required this.lmp,
    required this.edd,
    this.gravida = 1,
    this.para = 0,
    this.visitNumber = 1,
    this.aog,
    this.fundalHeight,
    this.fetalHeartTone,
    this.bloodPressure,
    this.weight,
    this.urinalysis,
    this.status = MaternalStatus.prenatal,
    this.notes,
    DateTime? createdAt,
    this.createdBy = '',
  }) : createdAt = createdAt ?? DateTime.now();

  int get trimester {
    final weeks = aog ?? DateTime.now().difference(lmp).inDays ~/ 7;
    if (weeks <= 12) return 1;
    if (weeks <= 27) return 2;
    return 3;
  }

  factory MaternalRecordModel.fromMap(Map<String, dynamic> map, String id) {
    return MaternalRecordModel(
      id: id,
      patientId: map['patientId'] ?? '',
      lmp: (map['lmp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      edd: (map['edd'] as Timestamp?)?.toDate() ?? DateTime.now(),
      gravida: map['gravida'] ?? 1,
      para: map['para'] ?? 0,
      visitNumber: map['visitNumber'] ?? 1,
      aog: map['aog'],
      fundalHeight: (map['fundalHeight'] as num?)?.toDouble(),
      fetalHeartTone: map['fetalHeartTone'],
      bloodPressure: map['bloodPressure'],
      weight: (map['weight'] as num?)?.toDouble(),
      urinalysis: map['urinalysis'],
      status: MaternalStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => MaternalStatus.prenatal,
      ),
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      createdBy: map['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'patientId': patientId,
        'lmp': Timestamp.fromDate(lmp),
        'edd': Timestamp.fromDate(edd),
        'gravida': gravida,
        'para': para,
        'visitNumber': visitNumber,
        'aog': aog,
        'fundalHeight': fundalHeight,
        'fetalHeartTone': fetalHeartTone,
        'bloodPressure': bloodPressure,
        'weight': weight,
        'urinalysis': urinalysis,
        'status': status.name,
        'notes': notes,
        'createdAt': Timestamp.fromDate(createdAt),
        'createdBy': createdBy,
      };
}
