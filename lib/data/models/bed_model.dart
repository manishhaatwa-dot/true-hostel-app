class BedModel {
  final String id;
  final String hostelId;
  final String roomId;
  final String bedNumber;
  final bool isOccupied;
  final String? studentId;

  const BedModel({
    required this.id,
    required this.hostelId,
    required this.roomId,
    required this.bedNumber,
    required this.isOccupied,
    this.studentId,
  });

  factory BedModel.fromJson(Map<String, dynamic> json) {
    return BedModel(
      id: json['id'] ?? '',
      hostelId: json['hostelId'] ?? '',
      roomId: json['roomId'] ?? '',
      bedNumber: json['bedNumber'] ?? '',
      isOccupied: json['isOccupied'] ?? false,
      studentId: json['studentId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostelId': hostelId,
      'roomId': roomId,
      'bedNumber': bedNumber,
      'isOccupied': isOccupied,
      'studentId': studentId,
    };
  }
}