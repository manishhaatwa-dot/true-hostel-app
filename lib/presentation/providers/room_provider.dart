import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_collections.dart';
import '../../data/models/room_model.dart';

class RoomState {
  final List<RoomModel> rooms;
  final bool isLoading;
  final String? errorMessage;

  RoomState({this.rooms = const [], this.isLoading = false, this.errorMessage});

  RoomState copyWith({List<RoomModel>? rooms, bool? isLoading, String? errorMessage}) {
    return RoomState(
      rooms: rooms ?? this.rooms,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class RoomNotifier extends StateNotifier<RoomState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RoomNotifier() : super(RoomState());

  // Listen stream to capture target multi-tenant hostels infrastructure rooms automatically
  void listenToRooms(String hostelId) {
    state = state.copyWith(isLoading: true);
    _firestore
        .collection(FirestoreCollections.rooms)
        .where('hostelId', isEqualTo: hostelId)
        .snapshots()
        .listen((snapshot) {
      final list = snapshot.docs.map((doc) => RoomModel.fromJson(doc.data())).toList();
      state = RoomState(rooms: list, isLoading: false);
    }, onError: (error) {
      state = RoomState(errorMessage: error.toString(), isLoading: false);
    });
  }

  // Automation adding entry execution node (Creates collection automatically if not exist)
  Future<void> addNewRoom(RoomModel room) async {
    try {
      await _firestore.collection(FirestoreCollections.rooms).doc(room.id).set(room.toJson());
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

final roomProvider = StateNotifierProvider<RoomNotifier, RoomState>((ref) {
  return RoomNotifier();
});