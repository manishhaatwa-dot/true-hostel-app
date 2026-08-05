class UserEntity {
  final String uid;
  final String hostelId;
  final String email;
  final String name;
  final String role; // Super Admin, Hostel Admin, Warden, Student, Parent
  final bool isActive;

  const UserEntity({
    required this.uid,
    required this.hostelId,
    required this.email,
    required this.name,
    required this.role,
    required this.isActive,
  });
}