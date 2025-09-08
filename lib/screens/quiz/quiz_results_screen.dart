import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/quiz_model.dart';
import '../../models/quiz_result_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../home/main_screen.dart';
import 'quiz_selection_screen.dart';

class QuizResultsScreen extends StatelessWidget {
  final Quiz quiz;
  final QuizResult result;

  const QuizResultsScreen({
    super.key,
    required this.quiz,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (result.score / result.totalQuestions * 100).round();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _getGradientColor(percentage),
              AppTheme.backgroundLight,
            ],
            stops: const [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Results Header
                Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: Center(
                        child: Icon(
                          _getResultIcon(percentage),
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ).animate()
                      .scale(duration: 800.ms, curve: Curves.elasticOut)
                      .then()
                      .shake(hz: 2, curve: Curves.easeInOutCubic),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      _getResultTitle(percentage),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ).animate()
                      .fadeIn(delay: 300.ms, duration: 800.ms)
                      .slideY(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      _getResultSubtitle(percentage),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withAlpha(230),
                      ),
                      textAlign: TextAlign.center,
                    ).animate()
                      .fadeIn(delay: 500.ms, duration: 800.ms)
                      .slideY(begin: 0.3, end: 0),
                  ],
                ),

                const SizedBox(height: 60),

                // Score Card
                Container(
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
                    children: [
                      // Main Score
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$percentage',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getScoreColor(percentage),
                            ),
                          ),
                          Text(
                            '%',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getScoreColor(percentage),
                            ),
                          ),
                        ],
                      ).animate()
                        .fadeIn(delay: 700.ms, duration: 800.ms)
                        .scaleXY(begin: 0.5, end: 1.0, curve: Curves.elasticOut),

                      const SizedBox(height: 16),

                      Text(
                        '${result.score} out of ${result.totalQuestions} correct',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ).animate()
                        .fadeIn(delay: 900.ms, duration: 800.ms)
                        .slideY(begin: 0.3, end: 0),

                      const SizedBox(height: 24),

                      // Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: _StatItem(
                              icon: Icons.timer_outlined,
                              label: 'Time',
                              value: _formatDuration(result.timeSpent),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey.shade300,
                          ),
                          Expanded(
                            child: _StatItem(
                              icon: Icons.quiz_outlined,
                              label: 'Questions',
                              value: '${result.totalQuestions}',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey.shade300,
                          ),
                          Expanded(
                            child: _StatItem(
                              icon: Icons.trending_up,
                              label: 'Accuracy',
                              value: '$percentage%',
                            ),
                          ),
                        ],
                      ).animate()
                        .fadeIn(delay: 1100.ms, duration: 800.ms)
                        .slideY(begin: 0.3, end: 0),
                    ],
                  ),
                ).animate()
                  .fadeIn(delay: 600.ms, duration: 800.ms)
                  .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 32),

                // Review Answers Section
                Container(
                  padding: const EdgeInsets.all(20),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.visibility,
                            color: AppTheme.primaryBlue,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Review Answers',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Column(
                        children: quiz.questions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final question = entry.value;
                          final userAnswer = result.userAnswers[index];
                          final isCorrect = userAnswer == question.options.indexOf(question.answer);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: _QuestionReview(
                              questionNumber: index + 1,
                              question: question,
                              userAnswer: userAnswer,
                              isCorrect: isCorrect,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ).animate()
                  .fadeIn(delay: 1300.ms, duration: 800.ms)
                  .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 32),

                // Action Buttons
                Column(
                  children: [
                    CustomButton(
                      text: 'Take Another Quiz',
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const QuizSelectionScreen()),
                        );
                      },
                      prefixIcon: Icons.refresh,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    CustomButton(
                      text: 'Back to Home',
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const MainScreen()),
                          (route) => false,
                        );
                      },
                      backgroundColor: Colors.white,
                      textColor: AppTheme.primaryBlue,
                      borderColor: AppTheme.primaryBlue,
                      prefixIcon: Icons.home,
                    ),
                  ],
                ).animate()
                  .fadeIn(delay: 1500.ms, duration: 800.ms)
                  .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getGradientColor(int percentage) {
    if (percentage >= 80) return AppTheme.success;
    if (percentage >= 60) return AppTheme.warning;
    return AppTheme.error;
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 80) return AppTheme.success;
    if (percentage >= 60) return AppTheme.warning;
    return AppTheme.error;
  }

  IconData _getResultIcon(int percentage) {
    if (percentage >= 80) return Icons.emoji_events;
    if (percentage >= 60) return Icons.thumb_up;
    return Icons.sentiment_neutral;
  }

  String _getResultTitle(int percentage) {
    if (percentage >= 80) return 'Excellent!';
    if (percentage >= 60) return 'Good Job!';
    return 'Keep Learning!';
  }

  String _getResultSubtitle(int percentage) {
    if (percentage >= 80) return 'You\'ve mastered this topic!';
    if (percentage >= 60) return 'You\'re on the right track!';
    return 'Review the material and try again';
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    }
    return '${remainingSeconds}s';
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryBlue,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _QuestionReview extends StatelessWidget {
  final int questionNumber;
  final QuizQuestion question;
  final int? userAnswer;
  final bool isCorrect;

  const _QuestionReview({
    required this.questionNumber,
    required this.question,
    required this.userAnswer,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final localUserAnswer = userAnswer;
    final correctAnswerIndex = question.options.indexOf(question.answer);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect 
            ? AppTheme.success.withAlpha(26)
            : AppTheme.error.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect 
              ? AppTheme.success.withAlpha(77)
              : AppTheme.error.withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCorrect ? AppTheme.success : AppTheme.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCorrect ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Question $questionNumber',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isCorrect ? AppTheme.success : AppTheme.error,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            question.question,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Text(
                'Your answer: ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                localUserAnswer != null ? '${String.fromCharCode(65 + localUserAnswer)} - ${question.options[localUserAnswer]}' : 'Not Answered',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isCorrect ? AppTheme.success : AppTheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          if (!isCorrect) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Correct answer: ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  '${String.fromCharCode(65 + correctAnswerIndex)} - ${question.answer}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            if (question.explanation != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        question.explanation!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}