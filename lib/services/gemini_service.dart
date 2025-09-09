import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:fii_smart/utils/constants.dart';
import '../models/quiz_model.dart';
import 'package:fii_smart/utils/logger.dart';

class GeminiService {
  final GenerativeModel _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: geminiApiKey);

  Map<String, dynamic> _parseJsonFromText(String? text) {
    if (text == null || text.trim().isEmpty) {
      throw const FormatException('Empty response from model');
    }
    var t = text.trim();
    // Strip triple backtick fences if present
    if (t.startsWith('```')) {
      // ```json
      // {...}
      // ```
      final fence = RegExp(r'^```[a-zA-Z]*\n([\s\S]*?)\n```', multiLine: true);
      final m = fence.firstMatch(t);
      if (m != null && m.groupCount >= 1) {
        t = m.group(1)!.trim();
      } else {
        // Remove all fences conservatively
        t = t.replaceAll(RegExp(r'^```[a-zA-Z]*'), '').replaceAll('```', '').trim();
      }
    }
    // Try direct decode first
    try {
      final decoded = jsonDecode(t);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'data': decoded};
    } catch (_) {
      // Try to extract the largest JSON object between first '{' and last '}'
      final start = t.indexOf('{');
      final end = t.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        final candidate = t.substring(start, end + 1);
        try {
          final decoded = jsonDecode(candidate);
          if (decoded is Map<String, dynamic>) return decoded;
          return {'data': decoded};
        } catch (e) {
          throw FormatException('Failed to parse JSON: ${e.toString()}');
        }
      }
      throw const FormatException('No JSON object found in model response');
    }
  }

  Future<Quiz> generateQuiz(String course, String subject, List<String> weaknesses, String pdfContext) async {
    final prompt = [
      'You are a quiz generator. Respond with RAW JSON only. Do not include markdown fences.',
      'Generate a multiple-choice quiz with exactly 10 questions.',
      'All the generated questions should be in Romanian language, as well as the answer options.',
      'Schema: {"questions": [{"question": string, "options": [string, string, string, string], "answer": string}]}.',
      'Course: $course. Subject: $subject.',
      if (weaknesses.isNotEmpty) 'Focus on these weaknesses: ${weaknesses.join(", ")}.',
      if (pdfContext.trim().isNotEmpty) 'Additional context: $pdfContext',
    ].join(' ');
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    final map = _parseJsonFromText(response.text);
    return Quiz.fromJson(map);
  }
  
  Future<Quiz> generateQuizFromEnhancedContent(String enhancedContent, String lessonTitle, int questionCount, 
      {String course = "", String subject = "", List<String> weaknesses = const []}) async {
    try {
      final List<String> promptParts = [
        'You are a quiz generator. Respond with RAW JSON only. Do not include markdown fences.',
        'Generate a multiple-choice quiz with exactly $questionCount questions based on this educational content for "$lessonTitle".',
        'Schema: {"questions": [{"question": string, "options": [string, string, string, string], "answer": string}]}.',
        'All the generated questions should be in Romanian language, as well as the answer options.',
      ];
      
      // Add course and subject if available
      if (course.isNotEmpty) {
        promptParts.add('Course: $course.');
      }
      
      if (subject.isNotEmpty) {
        promptParts.add('Subject: $subject.');
      }
      
      // Add weaknesses to focus on if any
      if (weaknesses.isNotEmpty) {
        promptParts.add('Focus especially on these topics: ${weaknesses.join(", ")}.');
      }
      
      // Add the enhanced content (which combines pre-defined content and user notes)
      promptParts.add('Content: $enhancedContent');
      
      final prompt = promptParts.join(' ');
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final map = _parseJsonFromText(response.text);
      
      return Quiz.fromJson(map);
    } catch (e) {
      Logger.error('Error generating quiz from enhanced content: $e');
      return Quiz(questions: []);
    }
  }
  
  // Generate explanations using the enhanced content
  Future<String> generateExplanation(String question, String correctAnswer, String enhancedContent) async {
    try {
      final prompt = [
        'You are an educational assistant. Provide a clear, concise explanation.',
        'Question: $question',
        'Correct Answer: $correctAnswer',
        'Based on this content: $enhancedContent',
        'Explain why this answer is correct, using specific information from the content.',
        'Keep your explanation under 200 words and focus on key concepts.',
        'Respond in Romanian.',
      ].join('\n');
      
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      return response.text ?? 'No explanation available.';
    } catch (e) {
      Logger.error('Error generating explanation: $e');
      return 'Unable to generate explanation: ${e.toString()}';
    }
  }

  Future<Map<String, dynamic>> gradeQuiz(Quiz quiz, Map<int, String> answers) async {
    try {
      // Convert the quiz to JSON with proper serialization
      final quizJson = quiz.toJson();
      final answersMap = answers.map((k, v) => MapEntry(k.toString(), v));
      
      final prompt = [
        'You are a quiz grader. Respond with RAW JSON only. Do not include markdown fences.',
        'Given a quiz and the user answers, return: {"score": number, "mistakes": array, "advice": string, "newWeaknesses": array<string>}.',
        'The "mistakes" array should list the questions the user got wrong with brief explanations.',
        'The "advice" should provide study tips based on the mistakes.',
        'All responses should be in Romanian.',
        'quiz:', jsonEncode(quizJson),
        'answers:', jsonEncode(answersMap),
      ].join(' ');
      
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return _parseJsonFromText(response.text);
    } catch (e) {
      Logger.error('Error grading quiz: $e');
      // Return a default response if grading fails
      return {
        'score': 0,
        'mistakes': ['Unable to grade quiz due to technical error'],
        'advice': 'Please try again later.',
        'newWeaknesses': <String>[]
      };
    }
  }
}