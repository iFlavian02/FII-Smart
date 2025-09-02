import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../services/content_service.dart';
import '../services/storage_service.dart';
import '../utils/logger.dart';

class UploadNotePage extends StatefulWidget {
  final String year;
  final String semester;
  final String course;
  final String lesson;
  
  const UploadNotePage({
    super.key,
    required this.year,
    required this.semester,
    required this.course,
    required this.lesson,
  });

  @override
  State<UploadNotePage> createState() => _UploadNotePageState();
}

class _UploadNotePageState extends State<UploadNotePage> {
  final ContentService _contentService = ContentService();
  final StorageService _storageService = StorageService();
  final _titleController = TextEditingController();
  
  bool _isLoading = false;
  String? _fileName;
  Uint8List? _fileBytes;
  
  Future<void> _pickPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _fileName = result.files.first.name;
          _fileBytes = result.files.first.bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: ${e.toString()}')),
        );
      }
    }
  }
  
  Future<String?> _extractTextFromPDF(Uint8List bytes) async {
    try {
      // Load the PDF document
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      
      // Extract text from all pages
      String text = '';
      for (int i = 0; i < document.pages.count; i++) {
        final PdfTextExtractor extractor = PdfTextExtractor(document);
        text += extractor.extractText(startPageIndex: i, endPageIndex: i);
        text += '\n\n';
      }
      
      // Dispose the document
      document.dispose();
      
      return text;
    } catch (e) {
      Logger.error('Error extracting text: $e');
      return null;
    }
  }
  
  Future<void> _uploadNote() async {
    if (_fileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a PDF file first')),
      );
      return;
    }
    
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title for your note')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      // 1. Extract text from PDF
      final extractedText = await _extractTextFromPDF(_fileBytes!);
      if (extractedText == null || extractedText.isEmpty) {
        throw Exception('Failed to extract text from PDF');
      }
      
      // 2. Upload PDF to Firebase Storage
      final pdfUrl = await _storageService.uploadFile(
        'notes/${user.uid}/${widget.year}/${widget.semester}/${widget.course}/${widget.lesson}/$_fileName', 
        _fileBytes!
      );
      
      // 3. Process and store the note with enhanced content
      await _contentService.processUserNote(
        user.uid,
        widget.year,
        widget.semester,
        widget.course,
        widget.lesson,
        _titleController.text,
        extractedText,
        pdfUrl,
      );
      
      // 4. Show success and navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note uploaded and processed successfully')),
        );
        Navigator.pop(context, true); // Return success result
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading note: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Lecture Notes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upload notes for: ${widget.lesson}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Note Title',
                      hintText: 'Enter a title for your notes',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _fileName ?? 'No file selected',
                          style: TextStyle(
                            color: _fileName != null ? Colors.black : Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _pickPDF,
                        child: const Text('Select PDF'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Note: We\'ll extract the text from your PDF and enhance it with our reference materials to create better quizzes.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _fileName != null ? _uploadNote : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Upload and Process'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
