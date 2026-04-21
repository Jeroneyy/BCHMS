import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class AppointmentModel {
  final String id;
  final String patientId;
  final String? patientName; // denormalized for display
  final DateTime date;
  final String time;
  final AppointmentType type;
  final AppointmentStatus status;
  final String? notes;
  final String? assignedTo;
  final String createdBy;
  final DateTime createdAt;

  AppointmentModel({
    required this.id,
    required this.patientId,
    this.patientName,
    required this.date,
    required this.time,
    this.type = AppointmentType.general,
    this.status = AppointmentStatus.scheduled,
    this.notes,
    this.assignedTo,
    this.createdBy = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AppointmentModel.fromMap(Map<String, dynamic> map, String id) {
    return AppointmentModel(
      id: id,
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'],
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      time: map['time'] ?? '',
      type: AppointmentType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => AppointmentType.general,
      ),
      status: AppointmentStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => AppointmentStatus.scheduled,
      ),
      notes: map['notes'],
      assignedTo: map['assignedTo'],
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'patientId': patientId,
        'patientName': patientName,
        'date': Timestamp.fromDate(date),
        'time': time,
        'type': type.name,
        'status': status.name,
        'notes': notes,
        'assignedTo': assignedTo,
        'createdBy': createdBy,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  AppointmentModel copyWith({
    AppointmentStatus? status,
    String? notes,
    String? assignedTo,
    DateTime? date,
    String? time,
    AppointmentType? type,
  }) {
    return AppointmentModel(
      id: id,
      patientId: patientId,
      patientName: patientName,
      date: date ?? this.date,
      time: time ?? this.time,
      type: type ?? this.type,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }
}
