import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/quiz_model.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';
import 'quiz_results_screen.dart';

class QuizScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizScreen({super.key, required this.quiz});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  List<int?> _userAnswers = [];
  DateTime? _startTime;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _userAnswers = List.filled(widget.quiz.questions.length, null);
    _startTime = DateTime.now();
  }

  bool get _isLastQuestion => _currentQuestionIndex == widget.quiz.questions.length - 1;
  bool get _hasAnsweredCurrentQuestion => _userAnswers[_currentQuestionIndex] != null;
  
  QuizQuestion get _currentQuestion => widget.quiz.questions[_currentQuestionIndex];

  void _selectAnswer(int answerIndex) {
    setState(() {
      _userAnswers[_currentQuestionIndex] = answerIndex;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  Future<void> _submitQuiz() async {
    if (_userAnswers.contains(null)) {
      _showIncompleteQuizDialog();
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final timeSpent = DateTime.now().difference(_startTime!).inSeconds;
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      final result = await quizProvider.submitQuizAnswers(
        _userAnswers.cast<int>(),
        timeSpent,
      );
      
      if (result != null) {
        // Update user statistics
        await userProvider.updateQuizStats(result.score, result.totalQuestions);
        
        // Mark lesson as completed if score is good
        if ((result.score / result.totalQuestions * 100).round() >= 70) {
          await userProvider.markLessonCompleted(widget.quiz.lessonName ?? 'Quiz');
        }
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => QuizResultsScreen(
                quiz: widget.quiz,
                result: result,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit quiz: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showIncompleteQuizDialog() {
    final unansweredQuestions = _userAnswers
        .asMap()
        .entries
        .where((entry) => entry.value == null)
        .map((entry) => entry.key + 1)
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Incomplete Quiz'),
        content: Text(
          'You haven\'t answered all questions yet. Please answer questions: ${unansweredQuestions.join(', ')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue Quiz'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _submitQuiz();
            },
            child: const Text('Submit Anyway'),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Quiz'),
        content: const Text('Are you sure you want to exit? Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue Quiz'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentQuestionIndex + 1) / widget.quiz.questions.length;
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        _showExitDialog();
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryBlue,
                AppTheme.backgroundLight,
              ],
              stops: [0.0, 0.3],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header with progress
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: _showExitDialog,
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                          Expanded(
                            child: Text(
                              widget.quiz.lessonName ?? 'Quiz',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 48), // Balance the close button
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Progress bar
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Question ${_currentQuestionIndex + 1} of ${widget.quiz.questions.length}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withAlpha(230),
                                ),
                              ),
                              Text(
                                '${(progress * 100).round()}%',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withAlpha(230),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white.withAlpha(77),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.3, end: 0),

                // Question Card
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Question Text
                        Text(
                          _currentQuestion.question,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ).animate()
                          .fadeIn(duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),

                        const SizedBox(height: 32),

                        // Answer Options
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: _currentQuestion.options.asMap().entries.map((entry) {
                                final index = entry.key;
                                final option = entry.value;
                                final isSelected = _userAnswers[_currentQuestionIndex] == index;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _AnswerOption(
                                    option: option,
                                    index: index,
                                    isSelected: isSelected,
                                    onTap: () => _selectAnswer(index),
                                  ),
                                ).animate()
                                  .fadeIn(delay: (300 + index * 100).ms, duration: 600.ms)
                                  .slideX(begin: 0.3, end: 0);
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Navigation Buttons
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      if (_currentQuestionIndex > 0) ...[
                        Expanded(
                          child: CustomButton(
                            text: 'Previous',
                            onPressed: _previousQuestion,
                            backgroundColor: Colors.white,
                            textColor: AppTheme.primaryBlue,
                            borderColor: AppTheme.primaryBlue,
                            prefixIcon: Icons.arrow_back,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      
                      Expanded(
                        child: CustomButton(
                          text: _isLastQuestion ? 'Submit Quiz' : 'Next',
                          onPressed: _hasAnsweredCurrentQuestion 
                              ? (_isLastQuestion ? _submitQuiz : _nextQuestion)
                              : null,
                          isLoading: _isSubmitting,
                          prefixIcon: _isLastQuestion ? Icons.check : Icons.arrow_forward,
                        ),
                      ),
                    ],
                  ),
                ).animate()
                  .fadeIn(delay: 800.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  final String option;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnswerOption({
    required this.option,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final optionLabel = String.fromCharCode(65 + index); // A, B, C, D

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue.withAlpha(26) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  optionLabel,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}