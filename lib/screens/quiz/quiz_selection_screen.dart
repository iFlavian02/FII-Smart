import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/user_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';
import 'quiz_screen.dart';

class QuizSelectionScreen extends StatefulWidget {
  const QuizSelectionScreen({super.key});

  @override
  State<QuizSelectionScreen> createState() => _QuizSelectionScreenState();
}

class _QuizSelectionScreenState extends State<QuizSelectionScreen> {
  String? _selectedLesson;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryBlue,
              AppTheme.secondaryTeal,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ).animate()
                      .fadeIn(duration: 600.ms)
                      .slideX(begin: -0.3, end: 0),
                    Expanded(
                      child: Text(
                        'Select Quiz Topic',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate()
                        .fadeIn(delay: 200.ms, duration: 600.ms)
                        .slideX(begin: -0.3, end: 0),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  'Choose a lesson to generate a quiz from your notes or our content library',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withAlpha(230),
                  ),
                ).animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 40),

                // Lesson Selection
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Topics',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate()
                        .fadeIn(delay: 600.ms, duration: 600.ms)
                        .slideX(begin: -0.3, end: 0),

                      const SizedBox(height: 20),

                      Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          final user = userProvider.currentUser;
                          final courses = user?.yearOfStudy != null 
                              ? userProvider.getCoursesForYear(user!.yearOfStudy!)
                              : _getDefaultLessons();

                          return Column(
                            children: courses.asMap().entries.map((entry) {
                              final index = entry.key;
                              final lesson = entry.value;
                              final isCompleted = user?.completedLessons.contains(lesson) ?? false;
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _LessonCard(
                                  lesson: lesson,
                                  isSelected: _selectedLesson == lesson,
                                  isCompleted: isCompleted,
                                  onTap: () {
                                    setState(() {
                                      _selectedLesson = lesson;
                                    });
                                  },
                                ),
                              ).animate()
                                .fadeIn(delay: (800 + index * 100).ms, duration: 600.ms)
                                .slideX(begin: 0.3, end: 0);
                            }).toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Generate Quiz Button
                      Consumer<QuizProvider>(
                        builder: (context, quizProvider, child) {
                          return CustomButton(
                            text: 'Generate Quiz',
                            onPressed: _selectedLesson != null && !quizProvider.isGenerating
                                ? () => _generateQuiz()
                                : null,
                            isLoading: quizProvider.isGenerating,
                            prefixIcon: Icons.auto_awesome,
                          );
                        },
                      ).animate()
                        .fadeIn(delay: 1200.ms, duration: 600.ms)
                        .slideY(begin: 0.3, end: 0),

                      if (_selectedLesson != null) ...[
                        const SizedBox(height: 16),
                        
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withAlpha(26),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.primaryBlue.withAlpha(77),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppTheme.primaryBlue,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'We\'ll generate a quiz using your uploaded notes for $_selectedLesson, or use our curated content if no notes are available.',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate()
                          .fadeIn(delay: 1400.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),
                      ],
                    ],
                  ),
                ).animate()
                  .fadeIn(delay: 500.ms, duration: 800.ms)
                  .slideY(begin: 0.3, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> _getDefaultLessons() {
    return [
      'Data Structures',
      'Algorithms',
      'Object-Oriented Programming',
      'Database Systems',
      'Computer Networks',
      'Operating Systems',
    ];
  }

  Future<void> _generateQuiz() async {
    if (_selectedLesson == null) return;

    try {
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final courseName = userProvider.currentUser?.selectedCourse ?? '';
      final quiz = await quizProvider.generateQuizFromNotes(_selectedLesson!, courseName);
      
      if (mounted && quiz != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => QuizScreen(quiz: quiz),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate quiz: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }
}

class _LessonCard extends StatelessWidget {
  final String lesson;
  final bool isSelected;
  final bool isCompleted;
  final VoidCallback onTap;

  const _LessonCard({
    required this.lesson,
    required this.isSelected,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue.withAlpha(26) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppTheme.primaryBlue 
                    : AppTheme.primaryBlue.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.book,
                color: isSelected ? Colors.white : AppTheme.primaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Generate quiz questions based on this topic',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isCompleted) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.success.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 12,
                      color: AppTheme.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Completed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.success,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(width: 12),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
