class LectureModel {
  final String id;
  final String title;
  final String content;
  final String courseId;
  final String subjectId;
  final String author;
  final Map<String, dynamic>? metadata;

  LectureModel({
    required this.id,
    required this.title,
    required this.content,
    required this.courseId,
    required this.subjectId,
    required this.author,
    this.metadata,
  });

  // Manual implementation until build_runner generates the code
  factory LectureModel.fromJson(Map<String, dynamic> json) {
    return LectureModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      courseId: json['courseId'] as String,
      subjectId: json['subjectId'] as String,
      author: json['author'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Manual implementation until build_runner generates the code
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'courseId': courseId,
      'subjectId': subjectId,
      'author': author,
      'metadata': metadata,
    };
  }
}
