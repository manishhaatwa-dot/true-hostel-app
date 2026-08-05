class NoticeModel {
  final String id;
  final String hostelId;
  final String title;
  final String content;
  final String postedBy;
  final String dateString; // YYYY-MM-DD
  final String targetRole; // All, Student, Warden, Parent

  const NoticeModel({
    required this.id,
    required this.hostelId,
    required this.title,
    required this.content,
    required this.postedBy,
    required this.dateString,
    required this.targetRole,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json['id'] ?? '',
      hostelId: json['hostelId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      postedBy: json['postedBy'] ?? '',
      dateString: json['dateString'] ?? '',
      targetRole: json['targetRole'] ?? 'All',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostelId': hostelId,
      'title': title,
      'content': content,
      'postedBy': postedBy,
      'dateString': dateString,
      'targetRole': targetRole,
    };
  }
}