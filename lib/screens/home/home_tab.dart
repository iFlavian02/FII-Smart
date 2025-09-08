import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/stats_card.dart';
import '../../widgets/recent_quiz_card.dart';
import '../quiz/quiz_selection_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

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
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final user = userProvider.currentUser;
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white.withAlpha(230),
                                ),
                              ),
                              Text(
                                user?.displayName?.split(' ').first ?? 'Student',
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: user?.photoURL != null 
                              ? NetworkImage(user!.photoURL!) 
                              : null,
                          backgroundColor: Colors.white.withAlpha(51),
                          child: user?.photoURL == null 
                              ? const Icon(Icons.person, color: Colors.white, size: 28)
                              : null,
                        ),
                      ],
                    );
                  },
                ).animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.3, end: 0),

                const SizedBox(height: 32),

                // Quick Stats
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final user = userProvider.currentUser;
                    return Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: 'Quizzes Taken',
                            value: user?.totalQuizzesTaken.toString() ?? '0',
                            icon: Icons.quiz,
                            color: AppTheme.secondaryTeal,
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
                    );
                  },
                ).animate()
                  .fadeIn(delay: 200.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 24),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ).animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .slideX(begin: -0.3, end: 0),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        title: 'Take Quiz',
                        subtitle: 'Start a new quiz',
                        icon: Icons.quiz,
                        color: AppTheme.primaryBlue,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const QuizSelectionScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _QuickActionCard(
                        title: 'Upload Notes',
                        subtitle: 'Add study material',
                        icon: Icons.upload_file,
                        color: AppTheme.accentOrange,
                        onTap: () {
                          // Navigate to upload notes screen
                        },
                      ),
                    ),
                  ],
                ).animate()
                  .fadeIn(delay: 600.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 32),

                // Recent Activity
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ).animate()
                  .fadeIn(delay: 800.ms, duration: 600.ms)
                  .slideX(begin: -0.3, end: 0),

                const SizedBox(height: 16),

                // Recent Quizzes (placeholder for now)
                ...List.generate(3, (index) => 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RecentQuizCard(
                      title: 'Data Structures Quiz ${index + 1}',
                      score: 85 + (index * 5),
                      totalQuestions: 10,
                      completedAt: DateTime.now().subtract(Duration(days: index + 1)),
                    ),
                  ),
                ).animate(interval: 100.ms)
                  .fadeIn(delay: 1000.ms, duration: 600.ms)
                  .slideX(begin: 0.3, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withAlpha(204),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 32,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withAlpha(230),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
