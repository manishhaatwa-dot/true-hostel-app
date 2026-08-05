class StudentModel {
  final String id;
  final String hostelId;
  final String name;
  final String email;
  final String roomNumber;
  final String bedNumber;
  final String parentId;
  final bool isActive;

  const StudentModel({
    required this.id,
    required this.hostelId,
    required this.name,
    required this.email,
    required this.roomNumber,
    required this.bedNumber,
    required this.parentId,
    required this.isActive,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] ?? '',
      hostelId: json['hostelId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      roomNumber: json['roomNumber'] ?? '',
      bedNumber: json['bedNumber'] ?? '',
      parentId: json['parentId'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostelId': hostelId,
      'name': name,
      'email': email,
      'roomNumber': roomNumber,
      'bedNumber': bedNumber,
      'parentId': parentId,
      'isActive': isActive,
    };
  }
}