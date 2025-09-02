import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './data_service.dart';

abstract class AuthService {
  Future<void> signIn(String email, String password);
  Future<void> signUp(String email, String password, String displayName);
  Future<void> signOut();
  User? get currentUser;
}

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final DataService _dataService = DataService();

  @override
  Future<void> signIn(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    
    // Update lastActive timestamp
    if (_firebaseAuth.currentUser != null) {
      await _firebaseAuth.currentUser!.getIdToken(true); // Force refresh
      await FirebaseFirestore.instance
        .collection('users')
        .doc(_firebaseAuth.currentUser!.uid)
        .update({'lastActive': FieldValue.serverTimestamp()});
    }
  }

  @override
  Future<void> signUp(String email, String password, [String? displayName]) async {
    // Create the user account in Firebase Auth
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email, 
      password: password
    );
    
    // Initialize the user's data in Firestore
    if (userCredential.user != null) {
      await _dataService.initializeUserData(
        userCredential.user!.uid,
        email,
        displayName ?? email.split('@')[0] // Use part of email as display name if none provided
      );
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  User? get currentUser => _firebaseAuth.currentUser;
}
