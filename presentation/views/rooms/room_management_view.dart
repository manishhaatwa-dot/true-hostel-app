import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../providers/room_provider.dart';
import '../../../data/models/room_model.dart';

class RoomManagementView extends ConsumerStatefulWidget {
  final String hostelId;
  const RoomManagementView({super.key, required this.hostelId});

  @override
  ConsumerState<RoomManagementView> createState() => _RoomManagementViewState();
}

class _RoomManagementViewState extends ConsumerState<RoomManagementView> {
  final _buildingController = TextEditingController();
  final _floorController = TextEditingController();
  final _roomNoController = TextEditingController();
  final _capacityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      ref.read(roomProvider.notifier).listenToRooms(widget.hostelId);
    });
  }

  @override
  void dispose() {
    _buildingController.dispose();
    _floorController.dispose();
    _roomNoController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _saveRoomStructure() {
    final building = _buildingController.text.trim();
    final floorStr = _floorController.text.trim();
    final roomNo = _roomNoController.text.trim();
    final capStr = _capacityController.text.trim();

    if (building.isNotEmpty && floorStr.isNotEmpty && roomNo.isNotEmpty && capStr.isNotEmpty) {
      final floor = int.tryParse(floorStr) ?? 0;
      final capacity = int.tryParse(capStr) ?? 0;
      final roomId = const Uuid().v4();

      final newRoom = RoomModel(
        id: roomId,
        hostelId: widget.hostelId,
        buildingName: building,
        floorNumber: floor,
        roomNumber: roomNo,
        capacity: capacity,
        availableBeds: capacity,
      );

      ref.read(roomProvider.notifier).addNewRoom(newRoom);

      _buildingController.clear();
      _floorController.clear();
      _roomNoController.clear();
      _capacityController.clear();
      Navigator.of(context).pop();
    }
  }

  void _showAddRoomDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configure New Inventory Room'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _buildingController, decoration: const InputDecoration(labelText: 'Building Name')),
              const SizedBox(height: 8),
              TextField(controller: _floorController, decoration: const InputDecoration(labelText: 'Floor Number'), keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextField(controller: _roomNoController, decoration: const InputDecoration(labelText: 'Room Identity / Code')),
              const SizedBox(height: 8),
              TextField(controller: _capacityController, decoration: const InputDecoration(labelText: 'Max Bed Capacity'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(onPressed: _saveRoomStructure, child: const Text('Deploy Room')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomState = ref.watch(roomProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Room & Bed Allocation Mapping')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRoomDialog,
        backgroundColor: const Color(0xFF1E3A8A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: roomState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : roomState.rooms.isEmpty
              ? const Center(child: Text('No active inventory nodes available. Click + to add.'))
              : ListView.builder(
                  itemCount: roomState.rooms.length,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final item = roomState.rooms[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.king_bed, color: Color(0xFF1E3A8A)),
                        title: Text('Room ${item.roomNumber} - ${item.buildingName} (Floor ${item.floorNumber})'),
                        subtitle: Text('Total Space: ${item.capacity} Beds | Occupied: ${item.occupiedBeds} | Free: ${item.availableBeds}'),
                      ),
                    );
                  },
                ),
    );
  }
}