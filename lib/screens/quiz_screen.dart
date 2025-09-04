import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../services/gemini_service.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';

class QuizScreen extends StatefulWidget {
  final Quiz quiz;
  const QuizScreen({super.key, required this.quiz});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final Map<int, String> _answers = {};
  final GeminiService _gemini = GeminiService();
  final DataService _data = DataService();
  final AuthService _auth = FirebaseAuthService();
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _submitQuiz() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final result = await _gemini.gradeQuiz(widget.quiz, _answers);
      final newWeaknesses = List<String>.from(result['newWeaknesses'] ?? []);

      await _data.updateWeaknesses(uid, newWeaknesses);
      // Convert the int keys to strings for Firestore compatibility
      final serializedAnswers = <String, String>{};
      _answers.forEach((key, value) {
        serializedAnswers[key.toString()] = value;
      });
      
      await _data.updateQuizHistory(uid, {
        'quiz': widget.quiz.toJson(),
        'answers': serializedAnswers,
        'results': result,
        'timestamp': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      await _showResultsDialog(result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _showResultsDialog(Map<String, dynamic> result) async {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C2333),
        title: Text(
          'Results: Score ${result['score']}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Mistakes:\n${(result['mistakes'] as List).join('\n')}',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                'Advice:\n${result['advice']}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text('OK', style: TextStyle(color: Color(0xFF8E6CFF))),
          )
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: const Color(0xFF8E6CFF).withAlpha(128), width: 1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_currentPage + 1}/${widget.quiz.questions.length}'),
        backgroundColor: const Color(0xFF0B0F19),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: (_currentPage + 1) / widget.quiz.questions.length,
            backgroundColor: const Color(0xFF1C2333),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8E6CFF)),
          ),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.quiz.questions.length,
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
        },
        itemBuilder: (context, index) {
          final q = widget.quiz.questions[index];
          return SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2333),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    q.question,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  ...q.options.map((opt) {
                    final selected = _answers[index] == opt;
                    return InkWell(
                      onTap: () => setState(() => _answers[index] = opt),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFF8E6CFF).withAlpha(51) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected ? const Color(0xFF8E6CFF) : const Color(0xFFAAB3C5).withAlpha(128),
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selected ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: selected ? const Color(0xFF8E6CFF) : const Color(0xFFAAB3C5),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                opt,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF1C2333),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentPage > 0)
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C3245),
                    foregroundColor: Colors.white,
                  ),
                ),
              const Spacer(),
              if (_currentPage < widget.quiz.questions.length - 1)
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C3245),
                    foregroundColor: Colors.white,
                  ),
                ),
              if (_currentPage == widget.quiz.questions.length - 1)
                Container(
                  decoration: BoxDecoration(
                    gradient: _answers.length == widget.quiz.questions.length
                        ? const LinearGradient(
                            colors: [Color(0xFF8E6CFF), Color(0xFF00E0FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: _answers.length == widget.quiz.questions.length
                        ? Colors.transparent
                        : const Color(0xFF2C3245),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text('Submit'),
                    onPressed: _answers.length == widget.quiz.questions.length ? _submitQuiz : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      disabledForegroundColor: const Color(0xFF6C748A),
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
