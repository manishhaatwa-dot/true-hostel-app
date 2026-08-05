class AttendanceModel {
  final String id;
  final String hostelId;
  final String studentId;
  final String studentName;
  final String roomNumber;
  final String date; // YYYY-MM-DD Format
  final String status; // Present, Absent, Leave
  final String markedBy;

  const AttendanceModel({
    required this.id,
    required this.hostelId,
    required this.studentId,
    required this.studentName,
    required this.roomNumber,
    required this.date,
    required this.status,
    required this.markedBy,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] ?? '',
      hostelId: json['hostelId'] ?? '',
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      roomNumber: json['roomNumber'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? 'Present',
      markedBy: json['markedBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostelId': hostelId,
      'studentId': studentId,
      'studentName': studentName,
      'roomNumber': roomNumber,
      'date': date,
      'status': status,
      'markedBy': markedBy,
    };
  }
}