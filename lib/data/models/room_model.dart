class RoomModel {
  final String id;
  final String hostelId;
  final String buildingName;
  final int floorNumber;
  final String roomNumber;
  final int capacity;
  final int availableBeds;

  const RoomModel({
    required this.id,
    required this.hostelId,
    required this.buildingName,
    required this.floorNumber,
    required this.roomNumber,
    required this.capacity,
    required this.availableBeds,
  });

  // Check calculation for occupancy flags
  int get occupiedBeds => capacity - availableBeds;

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? '',
      hostelId: json['hostelId'] ?? '',
      buildingName: json['buildingName'] ?? '',
      floorNumber: json['floorNumber'] ?? 0,
      roomNumber: json['roomNumber'] ?? '',
      capacity: json['capacity'] ?? 0,
      availableBeds: json['availableBeds'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostelId': hostelId,
      'buildingName': buildingName,
      'floorNumber': floorNumber,
      'roomNumber': roomNumber,
      'capacity': capacity,
      'availableBeds': availableBeds,
    };
  }
}