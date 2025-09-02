class PreDefinedContent {
  final String year;
  final String semester;
  final String course;
  final String lesson;
  final String content;

  PreDefinedContent({
    required this.year,
    required this.semester,
    required this.course,
    required this.lesson,
    required this.content,
  });

  // Manual implementation until build_runner generates the code
  factory PreDefinedContent.fromJson(Map<String, dynamic> json) {
    return PreDefinedContent(
      year: json['year'] as String,
      semester: json['semester'] as String,
      course: json['course'] as String,
      lesson: json['lesson'] as String,
      content: json['content'] as String,
    );
  }

  // Manual implementation until build_runner generates the code
  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'semester': semester,
      'course': course,
      'lesson': lesson,
      'content': content,
    };
  }
}
