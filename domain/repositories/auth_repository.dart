import '../entities/user_entity.dart';

abstract class AuthRepository {
  // Login karne ke liye interface contract rule
  Future<UserEntity> loginWithEmailAndPassword(String email, String password);
  
  // Current logged in user ka status check karne ke liye interface contract rule
  Future<UserEntity?> getCurrentUser();
  
  // Session signout karne ke liye interface contract rule
  Future<void> signOut();
}