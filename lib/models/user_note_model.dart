import 'package:cloud_firestore/cloud_firestore.dart';

class UserNote {
  final String id;
  final String userId;
  final String year;
  final String semester;
  final String course;
  final String lesson;
  final String title;
  final String originalText;
  final String enhancedText;
  final String pdfUrl;
  final DateTime uploadDate;

  UserNote({
    required this.id,
    required this.userId,
    required this.year,
    required this.semester,
    required this.course,
    required this.lesson,
    required this.title,
    required this.originalText,
    required this.enhancedText,
    required this.pdfUrl,
    required this.uploadDate,
  });

  factory UserNote.fromJson(Map<String, dynamic> json) {
    return UserNote(
      id: json['id'] as String,
      userId: json['userId'] as String,
      year: json['year'] as String,
      semester: json['semester'] as String,
      course: json['course'] as String,
      lesson: json['lesson'] as String,
      title: json['title'] as String,
      originalText: json['originalText'] as String,
      enhancedText: json['enhancedText'] as String,
      pdfUrl: json['pdfUrl'] as String,
      uploadDate: (json['uploadDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'year': year,
      'semester': semester,
      'course': course,
      'lesson': lesson,
      'title': title,
      'originalText': originalText,
      'enhancedText': enhancedText,
      'pdfUrl': pdfUrl,
      'uploadDate': uploadDate,
    };
  }
}
