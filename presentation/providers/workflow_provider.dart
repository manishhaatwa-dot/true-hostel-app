import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_collections.dart';
import '../../data/models/workflow_models.dart';

class WorkflowState {
  final List<ComplaintModel> complaints;
  final List<LeaveRequestModel> leaves;
  final List<VisitorPassModel> visitors;
  final bool isLoading;
  final String? errorMessage;

  WorkflowState({
    this.complaints = const [],
    this.leaves = const [],
    this.visitors = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  WorkflowState copyWith({
    List<ComplaintModel>? complaints,
    List<LeaveRequestModel>? leaves,
    List<VisitorPassModel>? visitors,
    bool? isLoading,
    String? errorMessage,
  }) {
    return WorkflowState(
      complaints: complaints ?? this.complaints,
      leaves: leaves ?? this.leaves,
      visitors: visitors ?? this.visitors,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class WorkflowNotifier extends StateNotifier<WorkflowState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  WorkflowNotifier() : super(WorkflowState());

  void listenToHostelWorkflow(String hostelId) {
    state = state.copyWith(isLoading: true);
    
    // Concurrent automated stream handlers for multi-tenant isolation tracking
    _firestore.collection(FirestoreCollections.complaints)
        .where('hostelId', isEqualTo: hostelId).snapshots().listen((snap) {
      final list = snap.docs.map((doc) => ComplaintModel.fromJson(doc.data())).toList();
      state = state.copyWith(complaints: list, isLoading: false);
    });

    _firestore.collection(FirestoreCollections.leaveRequests)
        .where('hostelId', isEqualTo: hostelId).snapshots().listen((snap) {
      final list = snap.docs.map((doc) => LeaveRequestModel.fromJson(doc.data())).toList();
      state = state.copyWith(leaves: list, isLoading: false);
    });

    _firestore.collection(FirestoreCollections.visitors)
        .where('hostelId', isEqualTo: hostelId).snapshots().listen((snap) {
      final list = snap.docs.map((doc) => VisitorPassModel.fromJson(doc.data())).toList();
      state = state.copyWith(visitors: list, isLoading: false);
    });
  }

  Future<void> logComplaint(ComplaintModel item) async {
    await _firestore.collection(FirestoreCollections.complaints).doc(item.id).set(item.toJson());
  }

  Future<void> resolveComplaint(String id, String status, String reply) async {
    await _firestore.collection(FirestoreCollections.complaints).doc(id).update({
      'status': status,
      'reply': reply,
    });
  }

  Future<void> submitLeaveRequest(LeaveRequestModel item) async {
    await _firestore.collection(FirestoreCollections.leaveRequests).doc(item.id).set(item.toJson());
  }

  Future<void> updateLeaveStatus(String id, String status) async {
    await _firestore.collection(FirestoreCollections.leaveRequests).doc(id).update({'status': status});
  }

  Future<void> requestVisitorPass(VisitorPassModel item) async {
    await _firestore.collection(FirestoreCollections.visitors).doc(item.id).set(item.toJson());
  }

  Future<void> processVisitorStatus(String id, String status) async {
    await _firestore.collection(FirestoreCollections.visitors).doc(id).update({'status': status});
  }
}

final workflowProvider = StateNotifierProvider<WorkflowNotifier, WorkflowState>((ref) {
  return WorkflowNotifier();
});