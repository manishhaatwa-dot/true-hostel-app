class HostelEntity {
  final String id;
  final String name;
  final String address;
  final String createdBy;
  final DateTime createdAt;

  const HostelEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.createdBy,
    required this.createdAt,
  });
}