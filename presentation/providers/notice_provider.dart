import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_collections.dart';
import '../../data/models/notice_model.dart';

class NoticeState {
  final List<NoticeModel> notices;
  final bool isLoading;
  final String? errorMessage;

  NoticeState({this.notices = const [], this.isLoading = false, this.errorMessage});

  NoticeState copyWith({List<NoticeModel>? notices, bool? isLoading, String? errorMessage}) {
    return NoticeState(
      notices: notices ?? this.notices,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class NoticeNotifier extends StateNotifier<NoticeState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  NoticeNotifier() : super(NoticeState());

  void listenToHostelNotices(String hostelId) {
    state = state.copyWith(isLoading: true);
    _firestore
        .collection(FirestoreCollections.notices)
        .where('hostelId', isEqualTo: hostelId)
        .snapshots()
        .listen((snapshot) {
      final list = snapshot.docs.map((doc) => NoticeModel.fromJson(doc.data())).toList();
      // Sorting notices by latest deployment configuration logic down to nodes
      list.sort((a, b) => b.dateString.compareTo(a.dateString));
      state = NoticeState(notices: list, isLoading: false);
    }, onError: (error) {
      state = NoticeState(errorMessage: error.toString(), isLoading: false);
    });
  }

  Future<void> dispatchNoticeBroadcast(NoticeModel notice) async {
    try {
      await _firestore.collection(FirestoreCollections.notices).doc(notice.id).set(notice.toJson());
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

final noticeProvider = StateNotifierProvider<NoticeNotifier, NoticeState>((ref) {
  return NoticeNotifier();
});