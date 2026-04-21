import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class PatientModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? middleName;
  final DateTime birthDate;
  final Sex sex;
  final String address;
  final String? contactNumber;
  final String? philhealthId;
  final BloodType bloodType;
  final CivilStatus civilStatus;
  final String? occupation;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final DateTime createdAt;
  final String createdBy;

  PatientModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.birthDate,
    required this.sex,
    required this.address,
    this.contactNumber,
    this.philhealthId,
    this.bloodType = BloodType.unknown,
    this.civilStatus = CivilStatus.single,
    this.occupation,
    this.emergencyContactName,
    this.emergencyContactPhone,
    DateTime? createdAt,
    this.createdBy = '',
  }) : createdAt = createdAt ?? DateTime.now();

  String get fullName {
    final middle = middleName != null && middleName!.isNotEmpty
        ? ' ${middleName![0]}.'
        : '';
    return '$firstName$middle $lastName';
  }

  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  factory PatientModel.fromMap(Map<String, dynamic> map, String id) {
    return PatientModel(
      id: id,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      middleName: map['middleName'],
      birthDate: (map['birthDate'] as Timestamp?)?.toDate() ?? DateTime(2000),
      sex: Sex.values.firstWhere(
        (s) => s.name == map['sex'],
        orElse: () => Sex.male,
      ),
      address: map['address'] ?? '',
      contactNumber: map['contactNumber'],
      philhealthId: map['philhealthId'],
      bloodType: BloodType.values.firstWhere(
        (b) => b.name == map['bloodType'],
        orElse: () => BloodType.unknown,
      ),
      civilStatus: CivilStatus.values.firstWhere(
        (c) => c.name == map['civilStatus'],
        orElse: () => CivilStatus.single,
      ),
      occupation: map['occupation'],
      emergencyContactName: map['emergencyContactName'],
      emergencyContactPhone: map['emergencyContactPhone'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      createdBy: map['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'firstName': firstName,
        'lastName': lastName,
        'middleName': middleName,
        'birthDate': Timestamp.fromDate(birthDate),
        'sex': sex.name,
        'address': address,
        'contactNumber': contactNumber,
        'philhealthId': philhealthId,
        'bloodType': bloodType.name,
        'civilStatus': civilStatus.name,
        'occupation': occupation,
        'emergencyContactName': emergencyContactName,
        'emergencyContactPhone': emergencyContactPhone,
        'createdAt': Timestamp.fromDate(createdAt),
        'createdBy': createdBy,
        // Searchable fields (lowercase for case-insensitive queries)
        'searchName': '${firstName.toLowerCase()} ${lastName.toLowerCase()}',
      };

  PatientModel copyWith({
    String? firstName,
    String? lastName,
    String? middleName,
    DateTime? birthDate,
    Sex? sex,
    String? address,
    String? contactNumber,
    String? philhealthId,
    BloodType? bloodType,
    CivilStatus? civilStatus,
    String? occupation,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) {
    return PatientModel(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      birthDate: birthDate ?? this.birthDate,
      sex: sex ?? this.sex,
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      philhealthId: philhealthId ?? this.philhealthId,
      bloodType: bloodType ?? this.bloodType,
      civilStatus: civilStatus ?? this.civilStatus,
      occupation: occupation ?? this.occupation,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      createdAt: createdAt,
      createdBy: createdBy,
    );
  }
}
