import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class NutritionRecordModel {
  final String id;
  final String patientId;
  final double weight;
  final double height;
  final int ageMonths;
  final NutritionStatus weightForAge;
  final NutritionStatus heightForAge;
  final NutritionStatus weightForHeight;
  final String? feedingType;
  final String? notes;
  final DateTime dateRecorded;
  final String createdBy;

  NutritionRecordModel({
    required this.id,
    required this.patientId,
    required this.weight,
    required this.height,
    required this.ageMonths,
    this.weightForAge = NutritionStatus.normal,
    this.heightForAge = NutritionStatus.normal,
    this.weightForHeight = NutritionStatus.normal,
    this.feedingType,
    this.notes,
    DateTime? dateRecorded,
    this.createdBy = '',
  }) : dateRecorded = dateRecorded ?? DateTime.now();

  factory NutritionRecordModel.fromMap(Map<String, dynamic> map, String id) {
    return NutritionRecordModel(
      id: id,
      patientId: map['patientId'] ?? '',
      weight: (map['weight'] as num?)?.toDouble() ?? 0,
      height: (map['height'] as num?)?.toDouble() ?? 0,
      ageMonths: map['ageMonths'] ?? 0,
      weightForAge: NutritionStatus.values.firstWhere(
        (s) => s.name == map['weightForAge'],
        orElse: () => NutritionStatus.normal,
      ),
      heightForAge: NutritionStatus.values.firstWhere(
        (s) => s.name == map['heightForAge'],
        orElse: () => NutritionStatus.normal,
      ),
      weightForHeight: NutritionStatus.values.firstWhere(
        (s) => s.name == map['weightForHeight'],
        orElse: () => NutritionStatus.normal,
      ),
      feedingType: map['feedingType'],
      notes: map['notes'],
      dateRecorded: (map['dateRecorded'] as Timestamp?)?.toDate(),
      createdBy: map['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'patientId': patientId,
        'weight': weight,
        'height': height,
        'ageMonths': ageMonths,
        'weightForAge': weightForAge.name,
        'heightForAge': heightForAge.name,
        'weightForHeight': weightForHeight.name,
        'feedingType': feedingType,
        'notes': notes,
        'dateRecorded': Timestamp.fromDate(dateRecorded),
        'createdBy': createdBy,
      };
}
