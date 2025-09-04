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
      
      // Extract text from all pages at once
      final String text = PdfTextExtractor(document).extractText();
      
      // Dispose the document
      document.dispose();
      
      return text;
    } catch (e) {
      Logger.error('Error extracting text from PDF: $e');
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
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Upload notes for: ${widget.lesson}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: const Color(0xFF8E6CFF).withAlpha(153),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                          color: Colors.white,
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: 'Enter a title for your notes',
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C2333),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF8E6CFF).withAlpha(128),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _fileName ?? 'No file selected',
                              style: TextStyle(
                                color: _fileName != null ? Colors.white : const Color(0xFFAAB3C5),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _pickPDF,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8E6CFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Select PDF'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Note: We\'ll extract the text from your PDF and enhance it with our reference materials to create better quizzes.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFAAB3C5),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: _fileName != null
                            ? const LinearGradient(
                                colors: [Color(0xFF8E6CFF), Color(0xFF00E0FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: _fileName != null ? Colors.transparent : const Color(0xFF2C3245),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ElevatedButton(
                        onPressed: _fileName != null ? _uploadNote : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Upload and Process',
                          style: TextStyle(
                            fontSize: 16,
                            color: _fileName != null ? Colors.white : const Color(0xFF6C748A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
