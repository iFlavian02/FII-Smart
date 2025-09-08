import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../models/quiz_model.dart';
import '../models/quiz_result_model.dart';
import '../services/gemini_service.dart';
import '../services/content_service.dart';
import 'user_provider.dart';

class QuizProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GeminiService _geminiService = GeminiService();
  final ContentService _contentService = ContentService();
  final UserProvider _userProvider;

  QuizProvider(this._userProvider);

  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;

  Quiz? _currentQuiz;
  Quiz? get currentQuiz => _currentQuiz;

  List<QuizResult> _userResults = [];
  List<QuizResult> get userResults => _userResults;

  void _setGenerating(bool generating) {
    _isGenerating = generating;
    notifyListeners();
  }

  Future<Quiz?> generateQuizFromNotes(String lessonName, String courseName) async {
    if (_auth.currentUser == null) return null;

    try {
      _setGenerating(true);

      String? notesContent = await _getUserNotesContent(lessonName);

      if (notesContent == null || notesContent.isEmpty) {
        notesContent = await _getDefaultLessonContent(lessonName);
      }

      if (notesContent == null || notesContent.isEmpty) {
        throw Exception('No content available for this lesson');
      }

      final enhancedContent = await _contentService.enhanceContent(
          await _getDefaultLessonContent(lessonName) ?? '', notesContent);

      final quiz = await _geminiService.generateQuizFromEnhancedContent(
        enhancedContent,
        lessonName,
        10, // Number of questions
        course: courseName,
        subject: lessonName,
        weaknesses: _userProvider.currentUser?.weaknesses ?? [],
      );

      if (quiz.questions.isEmpty) {
        throw Exception('Failed to generate quiz questions');
      }

      _currentQuiz = quiz;
      notifyListeners();

      return quiz;
    } catch (e) {
      debugPrint('Error generating quiz: $e');
      rethrow;
    } finally {
      _setGenerating(false);
    }
  }

  Future<bool> uploadNotes(String lessonName) async {
    if (_auth.currentUser == null) return false;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.isNotEmpty) {
        File file = File(result.files.single.path!);
        String fileName =
            '${_auth.currentUser!.uid}_${lessonName}_${DateTime.now().millisecondsSinceEpoch}';

        Reference ref = _storage.ref().child('notes').child(fileName);

        await ref.putFile(file);
        String downloadUrl = await ref.getDownloadURL();

        await _firestore
            .collection('user_notes')
            .doc('${_auth.currentUser!.uid}_$lessonName')
            .set({
          'userId': _auth.currentUser!.uid,
          'lessonName': lessonName,
          'fileName': result.files.single.name,
          'downloadUrl': downloadUrl,
          'uploadedAt': DateTime.now().millisecondsSinceEpoch,
        });

        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error uploading notes: $e');
      return false;
    }
  }

  Future<String?> _getUserNotesContent(String lessonName) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('user_notes')
          .doc('${_auth.currentUser!.uid}_$lessonName')
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String downloadUrl = data['downloadUrl'];

        http.Response response = await http.get(Uri.parse(downloadUrl));
        if (response.statusCode == 200) {
          return response.body;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user notes: $e');
      return null;
    }
  }

  Future<String?> _getDefaultLessonContent(String lessonName) async {
    try {
      return _getSampleLessonContent(lessonName);
    } catch (e) {
      debugPrint('Error getting default lesson content: $e');
      return null;
    }
  }

  String _getSampleLessonContent(String lessonName) {
    // ... (sample content remains the same)
    return '';
  }

  Future<QuizResult?> submitQuizAnswers(
      List<int> userAnswers, int timeSpent) async {
    if (_currentQuiz == null || _auth.currentUser == null) return null;

    try {
      int score = 0;
      for (int i = 0; i < _currentQuiz!.questions.length; i++) {
        if (i < userAnswers.length &&
            _currentQuiz!.questions[i].options.indexOf(_currentQuiz!.questions[i].answer) == userAnswers[i]) {
          score++;
        }
      }

      QuizResult result = QuizResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        quizId: _currentQuiz!.id,
        userId: _auth.currentUser!.uid,
        score: score,
        totalQuestions: _currentQuiz!.questions.length,
        userAnswers: userAnswers,
        completedAt: Timestamp.now(),
        timeSpent: timeSpent,
      );

      await _firestore
          .collection('quiz_results')
          .doc(result.id)
          .set(result.toMap());

      _userResults.insert(0, result);
      notifyListeners();

      return result;
    } catch (e) {
      debugPrint('Error submitting quiz answers: $e');
      return null;
    }
  }

  Future<void> loadUserResults() async {
    if (_auth.currentUser == null) return;

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('quiz_results')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .orderBy('completedAt', descending: true)
          .limit(50)
          .get();

      _userResults = snapshot.docs
          .map((doc) =>
              QuizResult.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user results: $e');
    }
  }

  Future<Quiz?> getQuizById(String quizId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('quizzes').doc(quizId).get();

      if (doc.exists) {
        return Quiz.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting quiz: $e');
      return null;
    }
  }
}
