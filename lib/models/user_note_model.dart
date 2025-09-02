class UserNote {
  final String id;
  final String userId;
  final String year;
  final String semester;
  final String course;
  final String lesson;
  final String title;
  final String originalText;  // Text extracted from PDF
  final String enhancedText;  // Text after combining with pre-defined content
  final String pdfUrl;        // Storage URL for the original PDF
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

  // Manual implementation until build_runner generates the code
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
      uploadDate: _timestampFromJson(json['uploadDate']),
    );
  }

  // Manual implementation until build_runner generates the code
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'year': year,
      'semester': semester,
      'course': course,
      'lesson': lesson,
      'title': title,
      'originalText': originalText,
      'enhancedText': enhancedText,
      'pdfUrl': pdfUrl,
      'uploadDate': _timestampToJson(uploadDate),
    };
  }
  
  // Helper methods for timestamp conversion
  static DateTime _timestampFromJson(dynamic timestamp) {
    if (timestamp is Map<String, dynamic> &&
        timestamp.containsKey('_seconds') &&
        timestamp.containsKey('_nanoseconds')) {
      return DateTime.fromMillisecondsSinceEpoch(
        timestamp['_seconds'] * 1000 +
            (timestamp['_nanoseconds'] / 1000000).round(),
      );
    }
    return DateTime.now();
  }

  static Map<String, dynamic> _timestampToJson(DateTime date) {
    return {
      '_seconds': date.millisecondsSinceEpoch ~/ 1000,
      '_nanoseconds': (date.millisecondsSinceEpoch % 1000) * 1000000,
    };
  }
}
