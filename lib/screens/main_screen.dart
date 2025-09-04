import 'package:fiismart/models/user_model.dart';
import 'package:fiismart/screens/quiz_screen.dart';
import 'package:fiismart/screens/upload_note_page.dart';
import 'package:fiismart/services/auth_service.dart';
import 'package:fiismart/services/content_service.dart';
import 'package:fiismart/services/data_service.dart';
import 'package:fiismart/services/gemini_service.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? _selectedYear, _selectedSemester, _selectedCourse, _selectedSubject;
  final List<String> _years = ['1', '2', '3'];
  List<String> _semesters = ['1', '2'], _courses = [], _subjects = [];
  bool _loading = false;
  final DataService _data = DataService();
  final GeminiService _gemini = GeminiService();
  final AuthService _auth = FirebaseAuthService();
  final ContentService _contentService = ContentService();
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
    // Load courses based on year and semester
    List<String> courses = [];
    
    //An 1
    if (year == '1' && semester == '1') {
      courses = ['SDA', 'Mate', 'ACSO', 'IP', 'Logica'];
    } else if (year == '1' && semester == '2') {
      courses = ['FAI', 'POO', 'PS', 'SO', 'PA'];
    } 

    //An2
    else if (year == '2' && semester == '1') {
      courses = ['RC', 'AG', 'BD', 'LFAC', 'PA'];
    } else if (year == '2' && semester == '2') {
      courses = ['IP', 'PA', 'SGBD', 'WEB'];
    } 

    //An3
    else if (year == '3' && semester == '1') {
      courses = ['SI', 'PYTHON', 'AI', 'ML', 'ISSA'];
    } else if (year == '3' && semester == '2') {
      courses = [];
    }

   
    
    setState(() {
      _courses = courses;
      _selectedCourse = null;
      _subjects = [];
      _selectedSubject = null;
    });
  }

  Future<void> _loadSubjects(String course) async {
    List<String> newSubjects = [];
    // Example: load subjects based on course
    if (course == 'SDA') {
      newSubjects = ['Algoritmi limbaj algoritmic', 'Analiza eficientei algiritmilor', 
                  'Analiza eficientei algiritmilor 2','Liste stive cozi','Coada cu prioritati',
                  'Arbori arbori binari','Grafuri','Arbori de cautare echilibrati',
                  'Sortare','Cautare','Arbori digitali','Tabele de dispersie'];
    } else if (course == 'FAI') {
      newSubjects = ['AI Basics', 'Machine Learning', 'Deep Learning'];
    } else if (course == 'RC') {
      newSubjects = ['Database Systems', 'SQL', 'NoSQL'];
    } else if (course == 'SI') {
      newSubjects = ['Software Engineering', 'Agile Methodologies', 'DevOps'];
    }

    setState(() {
      _subjects = newSubjects;
      _selectedSubject = null;
    });
  }

  Future<void> _generateQuiz() async {
    if (_selectedSubject == null) return;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    setState(() {
      _loading = true;
    });

    try {
      // 1. Fetch pre-defined content
      final preDefinedContent = await _contentService.getPreDefinedContent(
        _selectedYear!,
        _selectedSemester!,
        _selectedCourse!,
        _selectedSubject!,
      ) ?? '';

      // 2. Fetch user notes
      final userNotes = await _contentService.getUserNotes(
        uid,
        _selectedYear!,
        _selectedSemester!,
        _selectedCourse!,
        _selectedSubject!,
      );

      String finalContent;

      // 3. Combine content if user notes exist
      if (userNotes.isNotEmpty) {
        final userContent = userNotes.map((note) => note.originalText).join('\n\n');
        finalContent = await _contentService.enhanceContent(preDefinedContent, userContent);
      } else {
        finalContent = preDefinedContent;
      }

      // 4. Check if there is any content to generate a quiz from
      if (finalContent.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No content available for this lesson to generate a quiz.')),
          );
        }
        return;
      }

      // 5. Generate quiz
      final quiz = await _gemini.generateQuizFromEnhancedContent(
        finalContent,
        _selectedSubject!,
        10, // Number of questions
        course: _selectedCourse!,
        subject: _selectedSubject!,
        weaknesses: _user?.weaknesses ?? [],
      );

      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(quiz: quiz)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating quiz: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _navigateToUploadPage() {
    if (_selectedYear != null &&
        _selectedSemester != null &&
        _selectedCourse != null &&
        _selectedSubject != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UploadNotePage(
            year: _selectedYear!,
            semester: _selectedSemester!,
            course: _selectedCourse!,
            lesson: _selectedSubject!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a year, semester, course, and subject first.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Practice Quiz",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: const Color(0xFF8E6CFF).withAlpha(153),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout),
                          onPressed: _auth.signOut,
                          color: Colors.white,
                        )
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Dropdowns
                    _buildDropdown(
                      label: 'Select Year',
                      value: _selectedYear,
                      items: _years.map((y) => DropdownMenuItem(value: y, child: Text('Year $y'))).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedYear = val;
                          _selectedSemester = null;
                          _selectedCourse = null;
                          _selectedSubject = null;
                          _semesters = [];
                          _courses = [];
                          _subjects = [];
                        });
                        if (val != null) _loadSemesters(val);
                      },
                    ),
                    _buildDropdown(
                      label: 'Select Semester',
                      value: _selectedSemester,
                      items: _semesters.map((s) => DropdownMenuItem(value: s, child: Text('Semester $s'))).toList(),
                      onChanged: _selectedYear == null
                          ? null
                          : (val) {
                              setState(() {
                                _selectedSemester = val;
                                _selectedCourse = null;
                                _selectedSubject = null;
                                _courses = [];
                                _subjects = [];
                              });
                              if (val != null && _selectedYear != null) {
                                _loadCourses(_selectedYear!, val);
                              }
                            },
                    ),
                    _buildDropdown(
                      label: 'Select Course',
                      value: _selectedCourse,
                      items: _courses.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: _selectedSemester == null
                          ? null
                          : (val) {
                              setState(() {
                                _selectedCourse = val;
                                _selectedSubject = null;
                                _subjects = [];
                              });
                              if (val != null) {
                                _loadSubjects(val);
                              }
                            },
                    ),
                    _buildDropdown(
                      label: 'Select Subject',
                      value: _selectedSubject,
                      items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: _selectedCourse == null
                          ? null
                          : (val) {
                              setState(() {
                                _selectedSubject = val;
                              });
                            },
                    ),

                    const SizedBox(height: 40),

                    // Upload PDF Button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8E6CFF), Color(0xFF00E0FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ElevatedButton(
                        onPressed: _navigateToUploadPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Upload PDF",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Generate Quiz Button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _selectedSubject != null ? Colors.transparent : const Color(0xFF2C3245),
                        gradient: _selectedSubject != null
                            ? const LinearGradient(
                                colors: [Color(0xFF8E6CFF), Color(0xFF00E0FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ElevatedButton(
                        onPressed: _selectedSubject != null ? _generateQuiz : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          "Generate Quiz",
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedSubject != null ? Colors.white : const Color(0xFF6C748A),
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

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?)? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2333),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8E6CFF).withAlpha(128),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            label,
            style: const TextStyle(color: Color(0xFFAAB3C5)),
          ),
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          dropdownColor: const Color(0xFF1C2333),
          iconEnabledColor: const Color(0xFF8E6CFF),
        ),
      ),
    );
  }
}
