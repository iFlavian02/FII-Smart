import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<String> get weaknesses => _currentUser?.weaknesses ?? [];

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Load user data
  Future<void> loadUserData() async {
    if (_auth.currentUser == null) return;
    
    try {
      _setLoading(true);
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    int? yearOfStudy,
    int? semester,
    String? selectedCourse,
  }) async {
    if (_auth.currentUser == null || _currentUser == null) return;

    try {
      _setLoading(true);
      Map<String, dynamic> updates = {};
      
      if (displayName != null) updates['displayName'] = displayName;
      if (yearOfStudy != null) updates['yearOfStudy'] = yearOfStudy;
      if (semester != null) updates['semester'] = semester;
      if (selectedCourse != null) updates['selectedCourse'] = selectedCourse;
      
      updates['lastActive'] = DateTime.now().millisecondsSinceEpoch;

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update(updates);

      _currentUser = _currentUser!.copyWith(
        displayName: displayName ?? _currentUser!.displayName,
        yearOfStudy: yearOfStudy ?? _currentUser!.yearOfStudy,
        semester: semester ?? _currentUser!.semester,
        selectedCourse: selectedCourse ?? _currentUser!.selectedCourse,
        lastActive: DateTime.now(),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Mark lesson as completed
  Future<void> markLessonCompleted(String lessonName) async {
    if (_auth.currentUser == null || _currentUser == null) return;

    try {
      List<String> completedLessons = List.from(_currentUser!.completedLessons);
      if (!completedLessons.contains(lessonName)) {
        completedLessons.add(lessonName);
        
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({'completedLessons': completedLessons});

        _currentUser = _currentUser!.copyWith(completedLessons: completedLessons);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking lesson completed: $e');
    }
  }

  // Update quiz statistics
  Future<void> updateQuizStats(int score, int totalQuestions) async {
    if (_auth.currentUser == null || _currentUser == null) return;

    try {
      int newTotalQuizzes = _currentUser!.totalQuizzesTaken + 1;
      double newAverage = ((_currentUser!.averageScore * _currentUser!.totalQuizzesTaken) + 
          (score / totalQuestions * 100)) / newTotalQuizzes;

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({
        'totalQuizzesTaken': newTotalQuizzes,
        'averageScore': newAverage,
      });

      _currentUser = _currentUser!.copyWith(
        totalQuizzesTaken: newTotalQuizzes,
        averageScore: newAverage,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating quiz stats: $e');
    }
  }

  // Get available courses based on year
  List<String> getCoursesForYear(int year) {
    switch (year) {
      case 1:
        return [
          'Introduction to Computer Science',
          'Programming Fundamentals',
          'Mathematics for CS',
          'Digital Logic',
        ];
      case 2:
        return [
          'Data Structures',
          'Algorithms',
          'Computer Architecture',
          'Database Systems',
          'Software Engineering',
        ];
      case 3:
        return [
          'Operating Systems',
          'Computer Networks',
          'Machine Learning',
          'Web Development',
          'Mobile Development',
        ];
      default:
        return [];
    }
  }
}