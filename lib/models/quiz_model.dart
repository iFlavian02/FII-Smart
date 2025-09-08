class QuizQuestion {
  String question;
  List<String> options;
  String answer;
  String? explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
    this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] as String,
      options: List<String>.from(json['options']),
      answer: json['answer'] as String,
      explanation: json['explanation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'answer': answer,
      'explanation': explanation,
    };
  }
}

class Quiz {
  String? id;
  String? lessonName;
  List<QuizQuestion> questions;

  Quiz({this.id, this.lessonName, this.questions = const []});

  factory Quiz.fromMap(Map<String, dynamic> map, String id) {
    return Quiz(
      id: id,
      lessonName: map['lessonName'] as String?,
      questions: (map['questions'] as List<dynamic>?)
              ?.map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      lessonName: json['lessonName'] as String?,
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonName': lessonName,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}