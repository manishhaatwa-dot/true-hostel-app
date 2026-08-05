import '../../domain/entities/user_entity.dart';

class AppUserModel extends UserEntity {
  const AppUserModel({
    required super.uid,
    required super.hostelId,
    required super.email,
    required super.name,
    required super.role,
    required super.isActive,
  });

  // Firestore se data aane par use clean Dart object mein convert karne ke liye
  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      uid: json['uid'] ?? '',
      hostelId: json['hostelId'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'Student',
      isActive: json['isActive'] ?? true,
    );
  }

  // Data ko Firestore mein save karne ke liye JSON map mein convert karne ke liye
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'hostelId': hostelId,
      'email': email,
      'name': name,
      'role': role,
      'isActive': isActive,
    };
  }
}