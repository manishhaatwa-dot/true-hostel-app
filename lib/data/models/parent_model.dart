class ParentModel {
  final String id;
  final String hostelId;
  final String studentId;
  final String name;
  final String email;
  final String contactNumber;

  const ParentModel({
    required this.id,
    required this.hostelId,
    required this.studentId,
    required this.name,
    required this.email,
    required this.contactNumber,
  });

  factory ParentModel.fromJson(Map<String, dynamic> json) {
    return ParentModel(
      id: json['id'] ?? '',
      hostelId: json['hostelId'] ?? '',
      studentId: json['studentId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostelId': hostelId,
      'studentId': studentId,
      'name': name,
      'email': email,
      'contactNumber': contactNumber,
    };
  }
}