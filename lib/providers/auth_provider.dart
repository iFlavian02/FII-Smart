import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      _setLoading(true);
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _updateLastActive(result.user!.uid);
      return result;
    } catch (e) {
      debugPrint('Sign in error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmailPassword(String email, String password) async {
    try {
      _setLoading(true);
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user document
      await _createUserDocument(result.user!);
      return result;
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      _setLoading(true);
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      
      // Create or update user document
      await _createUserDocument(result.user!);
      return result;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!doc.exists) {
        UserModel userModel = UserModel(
          uid: user.uid,
          email: user.email!,
          displayName: user.displayName,
          photoURL: user.photoURL,
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );
        
        await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
      } else {
        await _updateLastActive(user.uid);
      }
    } catch (e) {
      debugPrint('Error creating user document: $e');
    }
  }

  // Update last active timestamp
  Future<void> _updateLastActive(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastActive': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      debugPrint('Error updating last active: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Password reset error: $e');
      rethrow;
    }
  }
}