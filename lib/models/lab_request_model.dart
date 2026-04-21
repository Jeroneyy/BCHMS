import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class LabRequestModel {
  final String id;
  final String patientId;
  final String? patientName;
  final LabTestType testType;
  final String? customTestName;
  final LabStatus status;
  final String requestedBy;
  final DateTime requestDate;
  final String? results;
  final DateTime? resultDate;
  final String? remarks;
  final DateTime createdAt;

  LabRequestModel({
    required this.id,
    required this.patientId,
    this.patientName,
    required this.testType,
    this.customTestName,
    this.status = LabStatus.pending,
    this.requestedBy = '',
    DateTime? requestDate,
    this.results,
    this.resultDate,
    this.remarks,
    DateTime? createdAt,
  })  : requestDate = requestDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  String get displayTestName =>
      testType == LabTestType.other ? customTestName ?? 'Other' : testType.label;

  factory LabRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return LabRequestModel(
      id: id,
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'],
      testType: LabTestType.values.firstWhere(
        (t) => t.name == map['testType'],
        orElse: () => LabTestType.other,
      ),
      customTestName: map['customTestName'],
      status: LabStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => LabStatus.pending,
      ),
      requestedBy: map['requestedBy'] ?? '',
      requestDate: (map['requestDate'] as Timestamp?)?.toDate(),
      results: map['results'],
      resultDate: (map['resultDate'] as Timestamp?)?.toDate(),
      remarks: map['remarks'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'patientId': patientId,
        'patientName': patientName,
        'testType': testType.name,
        'customTestName': customTestName,
        'status': status.name,
        'requestedBy': requestedBy,
        'requestDate': Timestamp.fromDate(requestDate),
        'results': results,
        'resultDate': resultDate != null ? Timestamp.fromDate(resultDate!) : null,
        'remarks': remarks,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
