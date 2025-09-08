import 'package:cloud_firestore/cloud_firestore.dart';

class QuizResult {
  final String id;
  final String? quizId;
  final String userId;
  final int score;
  final int totalQuestions;
  final int timeSpent; // in seconds
  final Timestamp completedAt;
  final List<int> userAnswers;

  QuizResult({
    required this.id,
    this.quizId,
    required this.userId,
    required this.score,
    required this.totalQuestions,
    required this.timeSpent,
    required this.completedAt,
    required this.userAnswers,
  });

  factory QuizResult.fromMap(Map<String, dynamic> map, String id) {
    return QuizResult(
      id: id,
      quizId: map['quizId'] as String?,
      userId: map['userId'] as String,
      score: map['score'] as int,
      totalQuestions: map['totalQuestions'] as int,
      timeSpent: map['timeSpent'] as int,
      completedAt: map['completedAt'] as Timestamp,
      userAnswers: List<int>.from(map['userAnswers']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quizId': quizId,
      'userId': userId,
      'score': score,
      'totalQuestions': totalQuestions,
      'timeSpent': timeSpent,
      'completedAt': completedAt,
      'userAnswers': userAnswers,
    };
  }
}