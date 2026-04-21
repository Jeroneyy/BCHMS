import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final String? phone;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
    DateTime? createdAt,
    this.phone,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => UserRole.viewer,
      ),
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      phone: map['phone'],
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role.name,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
        'phone': phone,
      };

  UserModel copyWith({
    String? name,
    String? email,
    UserRole? role,
    bool? isActive,
    String? phone,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      phone: phone ?? this.phone,
    );
  }
}
