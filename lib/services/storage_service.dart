import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload a file from a local path
  Future<String> uploadPDF(String uid, String filePath) async {
    final fileName = path.basename(filePath);
    final ref = _storage.ref('users/$uid/pdfs/${DateTime.now().toIso8601String()}_$fileName');
    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }
  
  // Upload a file from bytes (for web and mobile)
  Future<String> uploadFile(String storagePath, Uint8List fileBytes) async {
    final ref = _storage.ref(storagePath);
    await ref.putData(fileBytes);
    return await ref.getDownloadURL();
  }
  
  // Delete a file
  Future<void> deleteFile(String storagePath) async {
    final ref = _storage.ref(storagePath);
    await ref.delete();
  }

  Future<String> extractText(String filePath) async {
    // This is a placeholder for actual text extraction logic.
    // For PDF text extraction, we'll use a library like syncfusion_flutter_pdf
    // or a server-side function
    return 'Extracted summary from PDF...';
  }
}
