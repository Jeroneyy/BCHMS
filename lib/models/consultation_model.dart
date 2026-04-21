import 'package:cloud_firestore/cloud_firestore.dart';

class VitalSignsModel {
  final double? bloodPressureSystolic;
  final double? bloodPressureDiastolic;
  final double? temperature;
  final double? pulseRate;
  final double? respiratoryRate;
  final double? weight;
  final double? height;
  final double? oxygenSaturation;

  VitalSignsModel({
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.temperature,
    this.pulseRate,
    this.respiratoryRate,
    this.weight,
    this.height,
    this.oxygenSaturation,
  });

  String get bpReading {
    if (bloodPressureSystolic == null || bloodPressureDiastolic == null) {
      return 'N/A';
    }
    return '${bloodPressureSystolic!.toInt()}/${bloodPressureDiastolic!.toInt()}';
  }

  double? get bmi {
    if (weight == null || height == null || height == 0) return null;
    final heightM = height! / 100;
    return weight! / (heightM * heightM);
  }

  factory VitalSignsModel.fromMap(Map<String, dynamic> map) {
    return VitalSignsModel(
      bloodPressureSystolic: (map['bpSystolic'] as num?)?.toDouble(),
      bloodPressureDiastolic: (map['bpDiastolic'] as num?)?.toDouble(),
      temperature: (map['temperature'] as num?)?.toDouble(),
      pulseRate: (map['pulseRate'] as num?)?.toDouble(),
      respiratoryRate: (map['respiratoryRate'] as num?)?.toDouble(),
      weight: (map['weight'] as num?)?.toDouble(),
      height: (map['height'] as num?)?.toDouble(),
      oxygenSaturation: (map['oxygenSaturation'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'bpSystolic': bloodPressureSystolic,
        'bpDiastolic': bloodPressureDiastolic,
        'temperature': temperature,
        'pulseRate': pulseRate,
        'respiratoryRate': respiratoryRate,
        'weight': weight,
        'height': height,
        'oxygenSaturation': oxygenSaturation,
      };
}

class ConsultationModel {
  final String id;
  final String patientId;
  final String? appointmentId;
  final String chiefComplaint;
  final String? diagnosis;
  final String? treatment;
  final String? notes;
  final VitalSignsModel vitalSigns;
  final DateTime createdAt;
  final String createdBy;

  ConsultationModel({
    required this.id,
    required this.patientId,
    this.appointmentId,
    required this.chiefComplaint,
    this.diagnosis,
    this.treatment,
    this.notes,
    VitalSignsModel? vitalSigns,
    DateTime? createdAt,
    this.createdBy = '',
  })  : vitalSigns = vitalSigns ?? VitalSignsModel(),
        createdAt = createdAt ?? DateTime.now();

  factory ConsultationModel.fromMap(Map<String, dynamic> map, String id) {
    return ConsultationModel(
      id: id,
      patientId: map['patientId'] ?? '',
      appointmentId: map['appointmentId'],
      chiefComplaint: map['chiefComplaint'] ?? '',
      diagnosis: map['diagnosis'],
      treatment: map['treatment'],
      notes: map['notes'],
      vitalSigns: map['vitalSigns'] != null
          ? VitalSignsModel.fromMap(map['vitalSigns'])
          : null,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      createdBy: map['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'patientId': patientId,
        'appointmentId': appointmentId,
        'chiefComplaint': chiefComplaint,
        'diagnosis': diagnosis,
        'treatment': treatment,
        'notes': notes,
        'vitalSigns': vitalSigns.toMap(),
        'createdAt': Timestamp.fromDate(createdAt),
        'createdBy': createdBy,
      };
}
