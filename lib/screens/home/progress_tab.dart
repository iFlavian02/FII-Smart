import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/user_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/stats_card.dart';

class ProgressTab extends StatefulWidget {
  const ProgressTab({super.key});

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuizProvider>(context, listen: false).loadUserResults();
    });
  }

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
              AppTheme.backgroundLight,
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Your Progress',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.3, end: 0),

                const SizedBox(height: 8),

                Text(
                  'Track your learning journey',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withAlpha(230),
                  ),
                ).animate()
                  .fadeIn(delay: 200.ms, duration: 600.ms)
                  .slideY(begin: -0.3, end: 0),

                const SizedBox(height: 32),

                // Stats Overview
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final user = userProvider.currentUser;
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: StatsCard(
                                title: 'Total Quizzes',
                                value: user?.totalQuizzesTaken.toString() ?? '0',
                                icon: Icons.quiz,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: StatsCard(
                                title: 'Average Score',
                                value: '${user?.averageScore.toStringAsFixed(1) ?? '0'}%',
                                icon: Icons.trending_up,
                                color: AppTheme.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: StatsCard(
                                title: 'Lessons Done',
                                value: user?.completedLessons.length.toString() ?? '0',
                                icon: Icons.book_outlined,
                                color: AppTheme.secondaryTeal,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: StatsCard(
                                title: 'Study Streak',
                                value: '7', // This would be calculated based on activity
                                icon: Icons.local_fire_department,
                                color: AppTheme.accentOrange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ).animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 32),

                // Recent Quiz Results
                Text(
                  'Recent Quiz Results',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ).animate()
                  .fadeIn(delay: 600.ms, duration: 600.ms)
                  .slideX(begin: -0.3, end: 0),

                const SizedBox(height: 16),

                Consumer<QuizProvider>(
                  builder: (context, quizProvider, child) {
                    final results = quizProvider.userResults;
                    
                    if (results.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.quiz_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No quiz results yet',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Take your first quiz to see results here',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ).animate()
                        .fadeIn(delay: 800.ms, duration: 600.ms);
                    }

                    return Column(
                      children: results.take(10).map((result) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: _QuizResultCard(
                            title: 'Quiz Result',
                            score: result.score,
                            totalQuestions: result.totalQuestions,
                            completedAt: result.completedAt.toDate(),
                            timeSpent: result.timeSpent,
                          ),
                        );
                      }).toList()
                          .animate(interval: 100.ms)
                            .fadeIn(delay: 800.ms, duration: 600.ms)
                            .slideX(begin: 0.3, end: 0),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Learning Progress Chart (placeholder)
                Text(
                  'Learning Progress',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ).animate()
                  .fadeIn(delay: 1000.ms, duration: 600.ms)
                  .slideX(begin: -0.3, end: 0),

                const SizedBox(height: 16),

                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final user = userProvider.currentUser;
                    final courses = user?.yearOfStudy != null 
                        ? userProvider.getCoursesForYear(user!.yearOfStudy!)
                        : <String>[];

                    return Column(
                      children: courses.map((course) {
                        final isCompleted = user?.completedLessons.contains(course) ?? false;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: _CourseProgressCard(
                            courseName: course,
                            isCompleted: isCompleted,
                            progress: isCompleted ? 1.0 : 0.3, // Mock progress
                          ),
                        );
                      }).toList()
                          .animate(interval: 100.ms)
                            .fadeIn(delay: 1200.ms, duration: 600.ms)
                            .slideY(begin: 0.3, end: 0),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizResultCard extends StatelessWidget {
  final String title;
  final int score;
  final int totalQuestions;
  final DateTime completedAt;
  final int timeSpent;

  const _QuizResultCard({
    required this.title,
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
    required this.timeSpent,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (score / totalQuestions * 100).round();
    final timeAgo = _formatTimeAgo(completedAt);
    final duration = _formatDuration(timeSpent);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _getScoreColor(percentage).withAlpha(26),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '$percentage%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(percentage),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$score out of $totalQuestions correct',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$timeAgo • $duration',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              _getScoreIcon(percentage),
              color: _getScoreColor(percentage),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 80) return AppTheme.success;
    if (percentage >= 60) return AppTheme.warning;
    return AppTheme.error;
  }

  IconData _getScoreIcon(int percentage) {
    if (percentage >= 80) return Icons.emoji_events;
    if (percentage >= 60) return Icons.thumb_up;
    return Icons.trending_down;
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
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

class _CourseProgressCard extends StatelessWidget {
  final String courseName;
  final bool isCompleted;
  final double progress;

  const _CourseProgressCard({
    required this.courseName,
    required this.isCompleted,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    courseName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isCompleted)
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
                          size: 16,
                          color: AppTheme.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Complete',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
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
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? AppTheme.success : AppTheme.primaryBlue,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}