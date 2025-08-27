import 'package:file_picker/file_picker.dart';
import 'package:fiismart/models/user_model.dart';
import 'package:fiismart/screens/quiz_screen.dart';
import 'package:fiismart/services/auth_service.dart';
import 'package:fiismart/services/data_service.dart';
import 'package:fiismart/services/gemini_service.dart';
import 'package:fiismart/services/storage_service.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? _selectedYear, _selectedSemester, _selectedCourse, _selectedSubject;
  final List<String> _years = ['1', '2', '3'];
  List<String> _semesters = ['1', '2'], _courses = ['SDA','Mate','ACSO','IP','Engleza','Logica'], _subjects = [];
  bool _loading = false;
  final DataService _data = DataService();
  final StorageService _storage = StorageService();
  final GeminiService _gemini = GeminiService();
  final AuthService _auth = FirebaseAuthService();
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _loading = true);
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final user = await _data.getUser(uid);
        if (mounted) {
          setState(() {
            _user = user;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }


  Future<void> _loadSemesters(String year) async {
    // Example: load semesters based on year
    setState(() {
      _semesters = ['1', '2'];
      _selectedSemester = null;
      _courses = [];
      _selectedCourse = null;
      _subjects = [];
      _selectedSubject = null;
    });
  }

  Future<void> _loadCourses(String year, String semester) async {
    // Example: load courses based on year and semester
    setState(() {
      _courses = ['Math', 'CS', 'Physics'];
      _selectedCourse = null;
      _subjects = [];
      _selectedSubject = null;
    });
  }

  Future<void> _loadSubjects(String course) async {
    // Example: load subjects based on course
    setState(() {
      _subjects = ['Algebra', 'Programming', 'Mechanics'];
      _selectedSubject = null;
    });
  }

  Future<void> _uploadPDF() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      final filePath = result.files.single.path!;
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final ref = await _storage.uploadPDF(uid, filePath);
        final summary = await _storage.extractText(filePath);
        final newPdf = {'ref': ref, 'summary': summary};
        final updatedPdfs = List<Map<String, dynamic>>.from(_user?.pdfs ?? [])..add(newPdf);
        await _data.updateUser(uid, _user!..pdfs = updatedPdfs);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF uploaded and processed')));
        _loadInitialData();
      }
    }
  }

  Future<void> _generateQuiz() async {
    if (_selectedSubject == null) return;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final pdfContexts = _user?.pdfs.map((p) => p['summary'] ?? '').join('\n') ?? '';

    try {
      final quiz = await _gemini.generateQuiz(_selectedCourse ?? '', _selectedSubject ?? '', _user?.weaknesses ?? [], pdfContexts);
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(quiz: quiz)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating quiz: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Quiz'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _auth.signOut)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  DropdownButton<String>(
                    value: _selectedYear,
                    hint: const Text('Select Year'),
                    items: _years.map((y) => DropdownMenuItem(value: y, child: Text('Year $y'))).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedYear = val;
                        _selectedSemester = null;
                        _selectedCourse = null;
                        _selectedSubject = null;
                      });
                      if (val != null) _loadSemesters(val);
                    },
                  ),
                  DropdownButton<String>(
                    value: _selectedSemester,
                    hint: const Text('Select Semester'),
                    items: _semesters.map((s) => DropdownMenuItem(value: s, child: Text('Semester $s'))).toList(),
                    onChanged: _selectedYear == null || _semesters.isEmpty
                        ? null
                        : (val) {
                            setState(() {
                              _selectedSemester = val;
                              _selectedCourse = null;
                              _selectedSubject = null;
                            });
                            if (val != null && _selectedYear != null) {
                              _loadCourses(_selectedYear!, val);
                            }
                          },
                  ),
                  DropdownButton<String>(
                    value: _selectedCourse,
                    hint: const Text('Select Course'),
                    items: _courses.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: _selectedSemester == null || _courses.isEmpty
                        ? null
                        : (val) {
                            setState(() {
                              _selectedCourse = val;
                              _selectedSubject = null;
                            });
                            if (val != null) {
                              _loadSubjects(val);
                            }
                          },
                  ),
                  DropdownButton<String>(
                    value: _selectedSubject,
                    hint: const Text('Select Subject'),
                    items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: _selectedCourse == null || _subjects.isEmpty
                        ? null
                        : (val) {
                            setState(() {
                              _selectedSubject = val;
                            });
                          },
                  ),
                  ElevatedButton(onPressed: _uploadPDF, child: const Text('Upload PDF')),
                  ElevatedButton(
                    onPressed: _selectedYear != null && _selectedSemester != null && _selectedCourse != null && _selectedSubject != null ? _generateQuiz : null,
                    child: const Text('Generate Quiz'),
                  ),
                ],
              ),
      ),
    );
  }
}
