import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../utils/constants.dart';
import '../models/quiz_model.dart';

class GeminiService {
  final GenerativeModel _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: geminiApiKey);

  Map<String, dynamic> _parseJsonFromText(String? text) {
    if (text == null || text.trim().isEmpty) {
      throw const FormatException('Empty response from model');
    }
    var t = text.trim();
    // Strip triple backtick fences if present
    if (t.startsWith('```')) {
      // ```json\n{...}\n```
      final fence = RegExp(r'^```[a-zA-Z]*\n([\s\S]*?)\n```$', multiLine: true);
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

  Future<Map<String, dynamic>> gradeQuiz(Quiz quiz, Map<int, String> answers) async {
    final prompt = [
      'You are a quiz grader. Respond with RAW JSON only. Do not include markdown fences.',
      'Given a quiz and the user answers, return: {"score": number, "mistakes": array, "advice": string, "newWeaknesses": array<string>}.',
      'quiz:', jsonEncode(quiz.toJson()),
      'answers:', jsonEncode(answers.map((k, v) => MapEntry(k.toString(), v))),
    ].join(' ');
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return _parseJsonFromText(response.text);
  }
}
