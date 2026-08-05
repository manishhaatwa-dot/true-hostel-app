class ComplaintModel {
  final String id;
  final String hostelId;
  final String studentId;
  final String studentName;
  final String title;
  final String description;
  final String? imageUrl;
  final String status; // Pending, In_Progress, Resolved
  final String reply;

  const ComplaintModel({
    required this.id,
    required this.hostelId,
    required this.studentId,
    required this.studentName,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.status,
    required this.reply,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'] ?? '',
      hostelId: json['hostelId'] ?? '',
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      status: json['status'] ?? 'Pending',
      reply: json['reply'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostelId': hostelId,
      'studentId': studentId,
      'studentName': studentName,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'status': status,
      'reply': reply,
    };
  }
}

class LeaveRequestModel {
  final String id;
  final String hostelId;
  final String studentId;
  final String studentName;
  final String reason;
  final String startDate; // YYYY-MM-DD
  final String endDate;   // YYYY-MM-DD
  final String status; // Pending, Approved, Rejected

  const LeaveRequestModel({
    required this.id,
    required this.hostelId,
    required this.studentId,
    required this.studentName,
    required this.reason,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      id: json['id'] ?? '',
      hostelId: json['hostelId'] ?? '',
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      reason: json['reason'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      status: json['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostelId': hostelId,
      'studentId': studentId,
      'studentName': studentName,
      'reason': reason,
      'startDate': startDate,
      'endDate': endDate,
      'status': status,
    };
  }
}

class VisitorPassModel {
  final String id;
  final String hostelId;
  final String studentId;
  final String studentName;
  final String visitorName;
  final String relationship;
  final String entryTime;
  final String exitTime;
  final String status; // Pending, Approved, Denied, Checked_In, Checked_Out

  const VisitorPassModel({
    required this.id,
    required this.hostelId,
    required this.studentId,
    required this.studentName,
    required this.visitorName,
    required this.relationship,
    required this.entryTime,
    required this.exitTime,
    required this.status,
  });

  factory VisitorPassModel.fromJson(Map<String, dynamic> json) {
    return VisitorPassModel(
      id: json['id'] ?? '',
      hostelId: json['hostelId'] ?? '',
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      visitorName: json['visitorName'] ?? '',
      relationship: json['relationship'] ?? '',
      entryTime: json['entryTime'] ?? '',
      exitTime: json['exitTime'] ?? '',
      status: json['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostelId': hostelId,
      'studentId': studentId,
      'studentName': studentName,
      'visitorName': visitorName,
      'relationship': relationship,
      'entryTime': entryTime,
      'exitTime': exitTime,
      'status': status,
    };
  }
}