import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/data_service.dart';
import './logger.dart';

/// A utility class to handle Firebase Firestore database initialization
class DbInitializer {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DataService _dataService = DataService();
  
  /// Initialize the database structure
  /// Should be called when the app starts or during first login
  Future<void> initializeDatabase() async {
    try {
      // Check if the database has already been initialized
      await _dataService.initializeDatabaseSchema();
      Logger.info('Database schema initialized or verified successfully');
    } catch (e) {
      Logger.error('Error initializing database schema: $e');
    }
  }
  
  /// Ensure current user has data in Firestore
  Future<void> ensureUserData() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser != null) {
        // Get user document
        final userDoc = await _db.collection('users').doc(currentUser.uid).get();
        
        // If user document doesn't exist, create it
        if (!userDoc.exists) {
          await _dataService.initializeUserData(
            currentUser.uid, 
            currentUser.email ?? 'No email', 
            currentUser.displayName ?? currentUser.email?.split('@')[0] ?? 'User'
          );
          Logger.info('Created user data for ${currentUser.uid}');
        }
      }
    } catch (e) {
      Logger.error('Error ensuring user data: $e');
    }
  }
}

/// Call this at app startup to ensure the database is properly set up
Future<void> initializeFirestoreSchema() async {
  final initializer = DbInitializer();
  await initializer.initializeDatabase();
  await initializer.ensureUserData();
}
