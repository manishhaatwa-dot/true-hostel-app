import '../../domain/entities/hostel_entity.dart';

class TenantHostelModel extends HostelEntity {
  const TenantHostelModel({
    required super.id,
    required super.name,
    required super.address,
    required super.createdBy,
    required super.createdAt,
  });

  factory TenantHostelModel.fromJson(Map<String, dynamic> json) {
    return TenantHostelModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      createdBy: json['createdBy'] ?? '',
      createdAt: json['createdAt'] != null 
          ? (json['createdAt'] as Object).toString().contains('Timestamp')
              ? (json['createdAt'] as dynamic).toDate()
              : DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }
}