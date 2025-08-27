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
      await _data.updateQuizHistory(uid, {
        'quiz': widget.quiz.toJson(),
        'answers': _answers,
        'results': result,
        'timestamp': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Results: Score ${result['score']}'),
          content: Text('Mistakes: ${(result['mistakes'] as List).join('\n')}\nAdvice: ${result['advice']}'),
          actions: [TextButton(onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst), child: const Text('OK'))],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_currentPage + 1}/${widget.quiz.questions.length}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: (_currentPage + 1) / widget.quiz.questions.length,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
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
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q.question,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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
                            color: selected ? Colors.blue.withAlpha(20) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: selected ? Colors.blue : Colors.grey.shade300, width: selected ? 2 : 1),
                            boxShadow: [
                              if (selected)
                                BoxShadow(color: Colors.blue.withAlpha(40), blurRadius: 6, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? Colors.blue : Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(child: Text(opt, style: Theme.of(context).textTheme.bodyLarge)),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
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
                ),
              if (_currentPage == widget.quiz.questions.length - 1)
                ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('Submit'),
                  onPressed: _answers.length == widget.quiz.questions.length ? _submitQuiz : null,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
