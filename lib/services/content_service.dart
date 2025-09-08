import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/user_note_model.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

class ContentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GenerativeModel _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: geminiApiKey);
  
  // Get pre-defined content for a specific lesson
  Future<String?> getPreDefinedContent(String year, String semester, String course, String lesson) async {
    try {
      // Construct the document path
      final docPath = 'predefinedContent/$year/$semester/$course/$lesson';
      final docRef = _db.doc(docPath);
      
      final doc = await docRef.get();
      if (!doc.exists) {
        Logger.info('No pre-defined content found for: $docPath');
        return null;
      }
      
      return doc.data()?['content'];
    } catch (e) {
      Logger.error('Error getting pre-defined content: $e');
      return null;
    }
  }
  
  // Upload a new pre-defined content (admin function)
  Future<void> uploadPreDefinedContent(
    String year, String semester, String course, String lesson, String content) async {
    try {
      // Construct the document path
      final docPath = 'predefinedContent/$year/$semester/$course/$lesson';
      
      await _db.doc(docPath).set({
        'content': content,
        'year': year,
        'semester': semester,
        'course': course,
        'lesson': lesson,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      Logger.info('Pre-defined content uploaded successfully');
    } catch (e) {
      Logger.error('Error uploading pre-defined content: $e');
      rethrow;
    }
  }
  
  // Process and store a user's PDF note
  Future<UserNote> processUserNote(
    String userId, 
    String year, 
    String semester, 
    String course, 
    String lesson,
    String title,
    String extractedText,
    String pdfUrl
  ) async {
    try {
      // Create a new user note document
      final noteRef = _db.collection('users').doc(userId).collection('notes').doc();
      
      final userNote = UserNote(
        id: noteRef.id,
        userId: userId,
        year: year,
        semester: semester,
        course: course,
        lesson: lesson,
        title: title,
        originalText: extractedText,
        enhancedText: '', // Enhanced text is now generated on the fly
        pdfUrl: pdfUrl,
        uploadDate: DateTime.now(),
      );
      
      // Save to Firestore
      await noteRef.set(userNote.toJson());
      
      return userNote;
    } catch (e) {
      Logger.error('Error processing user note: $e');
      rethrow;
    }
  }
  
  // Get all notes for a specific user and lesson
  Future<List<UserNote>> getUserNotes(String userId, String year, String semester, String course, String lesson) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('notes')
          .where('year', isEqualTo: year)
          .where('semester', isEqualTo: semester)
          .where('course', isEqualTo: course)
          .where('lesson', isEqualTo: lesson)
          .get();
          
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID to the data
        return UserNote.fromJson(data);
      }).toList();
    } catch (e) {
      Logger.error('Error getting user notes: $e');
      return [];
    }
  }
  
  // Get all lessons with user notes for a specific course
  Future<List<String>> getLessonsWithNotes(String userId, String year, String semester, String course) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('notes')
          .where('year', isEqualTo: year)
          .where('semester', isEqualTo: semester)
          .where('course', isEqualTo: course)
          .get();
          
      // Extract unique lessons
      final Set<String> lessons = {};
      for (var doc in snapshot.docs) {
        lessons.add(doc.data()['lesson']);
      }
      
      return lessons.toList();
    } catch (e) {
      Logger.error('Error getting lessons with notes: $e');
      return [];
    }
  }
  
  // Public method to enhance content using Gemini
  Future<String> enhanceContent(String preDefinedContent, String extractedText) async {
    try {
      if (preDefinedContent.isEmpty) {
        // If no pre-defined content, just return the extracted text
        return extractedText;
      }
      
      final prompt = '''
You are an AI assistant that helps combine and enhance educational content.
I have two sources of information about the same topic:

SOURCE 1 (Pre-defined content):
$preDefinedContent

SOURCE 2 (Extracted from student notes):
$extractedText

Please combine these sources to create an enhanced, comprehensive version that:
1. Eliminates redundancies (don't repeat the same information)
2. Preserves unique information from both sources
3. Organizes the content logically
4. Maintains academic language and clarity
5. Keeps all important concepts, definitions, and examples

Return only the combined content, no explanations or comments.

The final content should be in Romanian language, like the text extracted from the student notes.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      return response.text ?? extractedText;
    } catch (e) {
      Logger.error('Error enhancing content: $e');
      // If there's an error, return the original extracted text
      return extractedText;
    }
  }
}
