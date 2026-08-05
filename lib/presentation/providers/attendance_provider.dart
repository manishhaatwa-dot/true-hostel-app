import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_collections.dart';
import '../../data/models/attendance_model.dart';

class AttendanceState {
  final List<AttendanceModel> attendanceRecords;
  final bool isLoading;
  final String? errorMessage;

  AttendanceState({
    this.attendanceRecords = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  AttendanceState copyWith({
    List<AttendanceModel>? attendanceRecords,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AttendanceState(
      attendanceRecords: attendanceRecords ?? this.attendanceRecords,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AttendanceNotifier() : super(AttendanceState());

  // Specific date aur hostel context ke mutabik attendance records load karna
  void listenToAttendanceByDate(String hostelId, String date) {
    state = state.copyWith(isLoading: true);
    _firestore
        .collection(FirestoreCollections.attendance)
        .where('hostelId', isEqualTo: hostelId)
        .where('date', isEqualTo: date)
        .snapshots()
        .listen((snapshot) {
      final list = snapshot.docs
          .map((doc) => AttendanceModel.fromJson(doc.data()))
          .toList();
      state = AttendanceState(attendanceRecords: list, isLoading: false);
    }, onError: (error) {
      state = AttendanceState(errorMessage: error.toString(), isLoading: false);
    });
  }

  // Attendance register mark aur batch-upload karne ka processor node
  Future<void> submitBulkAttendance(List<AttendanceModel> records) async {
    try {
      final batch = _firestore.batch();
      
      for (var record in records) {
        final docRef = _firestore
            .collection(FirestoreCollections.attendance)
            .doc(record.id);
        batch.set(docRef, record.toJson());
      }
      
      await batch.commit();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

final attendanceProvider = StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  return AttendanceNotifier();
});