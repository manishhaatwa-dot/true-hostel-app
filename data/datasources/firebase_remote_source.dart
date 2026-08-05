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

  // Automatic Multi-Tenant Master Registration: Creates all collections automatically on demand
  Future<void> autoInitializeNewHostelTenant({
    required String targetHostelId,
    required String hostelName,
    required String adminEmail,
    required String adminPassword,
    required String adminName,
  }) async {
    try {
      // 1. Create a dummy Auth User for testing the tenant allocation matrix
      final UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );

      final String adminUid = userCred.user!.uid;
      final writeBatch = _firestore.batch();

      // 2. Auto-initialize Hostels Document Collection Node
      final hostelRef = _firestore.collection(FirestoreCollections.hostels).doc(targetHostelId);
      writeBatch.set(hostelRef, {
        'id': targetHostelId,
        'name': hostelName,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': adminUid,
      });

      // 3. Auto-initialize Management Admin User Document Node
      final userRef = _firestore.collection(FirestoreCollections.users).doc(adminUid);
      writeBatch.set(userRef, {
        'uid': adminUid,
        'hostelId': targetHostelId,
        'email': adminEmail,
        'name': adminName,
        'role': 'Hostel Admin',
        'isActive': true,
      });

      // 4. Auto-initialize Sample Blueprint Systems Infrastructure Nodes (Rooms & Notices)
      // This forces Firestore to instantly allocate indexing pipelines for your entire app schema!
      final sampleRoomRef = _firestore.collection(FirestoreCollections.rooms).doc('${targetHostelId}_sample_room');
      writeBatch.set(sampleRoomRef, {
        'id': '${targetHostelId}_sample_room',
        'hostelId': targetHostelId,
        'buildingName': 'Main Block A',
        'floorNumber': 1,
        'roomNumber': '101-Alpha',
        'capacity': 4,
        'availableBeds': 4,
      });

      final sampleNoticeRef = _firestore.collection(FirestoreCollections.notices).doc('${targetHostelId}_welcome');
      writeBatch.set(sampleNoticeRef, {
        'id': '${targetHostelId}_welcome',
        'hostelId': targetHostelId,
        'title': 'Welcome to Opnora Whitelabel Node',
        'content': 'System infrastructure auto-allocated successfully for this host node network.',
        'postedBy': 'System Engine',
        'dateString': '2026-08-05',
        'targetRole': 'All',
      });

      // Execute atomic dynamic batch transaction parameters straight to Google Cloud
      await writeBatch.commit();
    } catch (e) {
      throw Exception("Automated Tenant Collection Registry Allocation Failed: ${e.toString()}");
    }
  }

  // Fetch active session credentials tracking loops
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

  Future<void> endSession() async {
    await _auth.signOut();
  }
}
