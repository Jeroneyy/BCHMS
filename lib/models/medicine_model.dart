import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class MedicineModel {
  final String id;
  final String name;
  final String? genericName;
  final MedicineCategory category;
  final MedicineUnit unit;
  final int currentStock;
  final int reorderLevel;
  final DateTime? expiryDate;
  final String? batchNumber;
  final String? notes;
  final DateTime createdAt;

  MedicineModel({
    required this.id,
    required this.name,
    this.genericName,
    this.category = MedicineCategory.other,
    this.unit = MedicineUnit.tablet,
    this.currentStock = 0,
    this.reorderLevel = 10,
    this.expiryDate,
    this.batchNumber,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isLowStock => currentStock <= reorderLevel;
  bool get isExpired =>
      expiryDate != null && expiryDate!.isBefore(DateTime.now());

  factory MedicineModel.fromMap(Map<String, dynamic> map, String id) {
    return MedicineModel(
      id: id,
      name: map['name'] ?? '',
      genericName: map['genericName'],
      category: MedicineCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => MedicineCategory.other,
      ),
      unit: MedicineUnit.values.firstWhere(
        (u) => u.name == map['unit'],
        orElse: () => MedicineUnit.tablet,
      ),
      currentStock: map['currentStock'] ?? 0,
      reorderLevel: map['reorderLevel'] ?? 10,
      expiryDate: (map['expiryDate'] as Timestamp?)?.toDate(),
      batchNumber: map['batchNumber'],
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'genericName': genericName,
        'category': category.name,
        'unit': unit.name,
        'currentStock': currentStock,
        'reorderLevel': reorderLevel,
        'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
        'batchNumber': batchNumber,
        'notes': notes,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

class DispensingRecordModel {
  final String id;
  final String patientId;
  final String medicineId;
  final String? medicineName;
  final int quantity;
  final String dispensedBy;
  final DateTime dispensedAt;
  final String? purpose;

  DispensingRecordModel({
    required this.id,
    required this.patientId,
    required this.medicineId,
    this.medicineName,
    required this.quantity,
    this.dispensedBy = '',
    DateTime? dispensedAt,
    this.purpose,
  }) : dispensedAt = dispensedAt ?? DateTime.now();

  factory DispensingRecordModel.fromMap(Map<String, dynamic> map, String id) {
    return DispensingRecordModel(
      id: id,
      patientId: map['patientId'] ?? '',
      medicineId: map['medicineId'] ?? '',
      medicineName: map['medicineName'],
      quantity: map['quantity'] ?? 0,
      dispensedBy: map['dispensedBy'] ?? '',
      dispensedAt: (map['dispensedAt'] as Timestamp?)?.toDate(),
      purpose: map['purpose'],
    );
  }

  Map<String, dynamic> toMap() => {
        'patientId': patientId,
        'medicineId': medicineId,
        'medicineName': medicineName,
        'quantity': quantity,
        'dispensedBy': dispensedBy,
        'dispensedAt': Timestamp.fromDate(dispensedAt),
        'purpose': purpose,
      };
}
