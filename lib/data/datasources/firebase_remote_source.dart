import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/firestore_collections.dart';
import '../models/app_user_model.dart';

class FirebaseRemoteSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign In implementation contract with automated validation routing
  Future<AppUserModel> loginUser(String email, String password) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception("Authentication lifecycle generated null reference entity.");
      }

      // Automatically look up structural node inside multi-tenant user registry
      final DocumentSnapshot doc = await _firestore
          .collection(FirestoreCollections.users)
          .doc(credential.user!.uid)
          .get();

      if (!doc.exists) {
        throw Exception("User data allocation profile missing from target engine repository.");
      }

      return AppUserModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception("Core Handshake Authentication Failure: ${e.toString()}");
    }
  }

  // Auto session fetch execution
  Future<AppUserModel?> fetchCurrentSession() async {
    final User? user = _auth.currentUser;
    if (user == null) return null;

    final DocumentSnapshot doc = await _firestore
        .collection(FirestoreCollections.users)
        .doc(user.uid)
        .get();

    if (!doc.exists) return null;
    return AppUserModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  // Clear Session state allocation parameters securely
  Future<void> endSession() async {
    await _auth.signOut();
  }
}