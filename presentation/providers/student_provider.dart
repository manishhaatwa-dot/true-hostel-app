import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_collections.dart';
import '../../data/models/student_model.dart';

class StudentState {
  final List<StudentModel> students;
  final bool isLoading;
  final String? errorMessage;

  StudentState({this.students = const [], this.isLoading = false, this.errorMessage});

  StudentState copyWith({List<StudentModel>? students, bool? isLoading, String? errorMessage}) {
    return StudentState(
      students: students ?? this.students,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class StudentNotifier extends StateNotifier<StudentState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StudentNotifier() : super(StudentState());

  void listenToStudents(String hostelId) {
    state = state.copyWith(isLoading: true);
    _firestore
        .collection(FirestoreCollections.students)
        .where('hostelId', isEqualTo: hostelId)
        .snapshots()
        .listen((snapshot) {
      final list = snapshot.docs.map((doc) => StudentModel.fromJson(doc.data())).toList();
      state = StudentState(students: list, isLoading: false);
    }, onError: (error) {
      state = StudentState(errorMessage: error.toString(), isLoading: false);
    });
  }

  Future<void> onboardNewStudent(StudentModel student) async {
    try {
      await _firestore.collection(FirestoreCollections.students).doc(student.id).set(student.toJson());
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

final studentProvider = StateNotifierProvider<StudentNotifier, StudentState>((ref) {
  return StudentNotifier();
});