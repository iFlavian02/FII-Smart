class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final int? yearOfStudy;
  final int? semester;
  final String? selectedCourse;
  final List<String> completedLessons;
  final int totalQuizzesTaken;
  final double averageScore;
  final DateTime createdAt;
  final DateTime lastActive;
  final List<String> weaknesses;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.yearOfStudy,
    this.semester,
    this.selectedCourse,
    this.completedLessons = const [],
    this.totalQuizzesTaken = 0,
    this.averageScore = 0.0,
    required this.createdAt,
    required this.lastActive,
    this.weaknesses = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      photoURL: map['photoURL'],
      yearOfStudy: map['yearOfStudy'],
      semester: map['semester'],
      selectedCourse: map['selectedCourse'],
      completedLessons: List<String>.from(map['completedLessons'] ?? []),
      totalQuizzesTaken: map['totalQuizzesTaken'] ?? 0,
      averageScore: (map['averageScore'] ?? 0.0).toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastActive: DateTime.fromMillisecondsSinceEpoch(map['lastActive'] ?? 0),
      weaknesses: List<String>.from(map['weaknesses'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'yearOfStudy': yearOfStudy,
      'semester': semester,
      'selectedCourse': selectedCourse,
      'completedLessons': completedLessons,
      'totalQuizzesTaken': totalQuizzesTaken,
      'averageScore': averageScore,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastActive': lastActive.millisecondsSinceEpoch,
      'weaknesses': weaknesses,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    int? yearOfStudy,
    int? semester,
    String? selectedCourse,
    List<String>? completedLessons,
    int? totalQuizzesTaken,
    double? averageScore,
    DateTime? createdAt,
    DateTime? lastActive,
    List<String>? weaknesses,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      semester: semester ?? this.semester,
      selectedCourse: selectedCourse ?? this.selectedCourse,
      completedLessons: completedLessons ?? this.completedLessons,
      totalQuizzesTaken: totalQuizzesTaken ?? this.totalQuizzesTaken,
      averageScore: averageScore ?? this.averageScore,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      weaknesses: weaknesses ?? this.weaknesses,
    );
  }
}