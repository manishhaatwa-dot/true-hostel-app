import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/firebase_remote_source.dart';
import '../../data/models/app_user_model.dart';

class AuthState {
  final AppUserModel? user;
  final bool isLoading;
  final String? errorMessage;

  AuthState({this.user, this.isLoading = false, this.errorMessage});

  AuthState copyWith({AppUserModel? user, bool? isLoading, String? errorMessage}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseRemoteSource _remoteSource = FirebaseRemoteSource();

  AuthNotifier() : super(AuthState()) {
    checkActiveSession();
  }

  Future<void> checkActiveSession() async {
    state = state.copyWith(isLoading: true);
    try {
      final sessionUser = await _remoteSource.fetchCurrentSession();
      state = AuthState(user: sessionUser, isLoading: false);
    } catch (e) {
      state = AuthState(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> performLogin(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final appUser = await _remoteSource.loginUser(email, password);
      state = AuthState(user: appUser, isLoading: false);
    } catch (e) {
      state = AuthState(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _remoteSource.endSession();
    state = AuthState(user: null, isLoading: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});