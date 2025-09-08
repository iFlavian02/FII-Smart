import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';
import '../profile/profile_setup_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

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
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final user = userProvider.currentUser;
                    return Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: user?.photoURL != null 
                                ? NetworkImage(user!.photoURL!) 
                                : null,
                            backgroundColor: Colors.white.withAlpha(51),
                            child: user?.photoURL == null 
                                ? const Icon(Icons.person, color: Colors.white, size: 60)
                                : null,
                          ).animate()
                            .scale(duration: 600.ms, curve: Curves.elasticOut),
                          
                          const SizedBox(height: 16), 
                          
                          Text(
                            user?.displayName ?? user?.email ?? 'Student',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate()
                            .fadeIn(delay: 200.ms, duration: 600.ms)
                            .slideY(begin: 0.3, end: 0),
                          
                          const SizedBox(height: 8), 
                          
                          Text(
                            user?.email ?? '',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withAlpha(230),
                            ),
                          ).animate()
                            .fadeIn(delay: 400.ms, duration: 600.ms)
                            .slideY(begin: 0.3, end: 0),
                          
                          if (user?.yearOfStudy != null && user?.semester != null) ...[
                            const SizedBox(height: 8), 
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(51),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Year ${user!.yearOfStudy} • Semester ${user.semester}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ).animate()
                              .fadeIn(delay: 600.ms, duration: 600.ms)
                              .slideY(begin: 0.3, end: 0),
                          ],
                        ],
                      ),
                    );
                  },
                ),

                // Stats Summary
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final user = userProvider.currentUser;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
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
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatItem(
                              title: 'Quizzes\nCompleted',
                              value: user?.totalQuizzesTaken.toString() ?? '0',
                              icon: Icons.quiz,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: Colors.grey.shade300,
                          ),
                          Expanded(
                            child: _StatItem(
                              title: 'Average\nScore',
                              value: '${user?.averageScore.toStringAsFixed(1) ?? '0'}%',
                              icon: Icons.trending_up,
                              color: AppTheme.success,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: Colors.grey.shade300,
                          ),
                          Expanded(
                            child: _StatItem(
                              title: 'Lessons\nCompleted',
                              value: user?.completedLessons.length.toString() ?? '0',
                              icon: Icons.book,
                              color: AppTheme.accentOrange,
                            ),
                          ),
                        ],
                      ),
                    ).animate()
                      .fadeIn(delay: 800.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0);
                  },
                ),

                const SizedBox(height: 32), 

                // Menu Items
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
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
                      _MenuTile(
                        icon: Icons.edit,
                        title: 'Edit Profile',
                        subtitle: 'Update your information',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
                          );
                        },
                      ),
                      const Divider(height: 1), 
                      _MenuTile(
                        icon: Icons.history,
                        title: 'Quiz History',
                        subtitle: 'View all your past quizzes',
                        onTap: () {
                          // Navigate to quiz history
                        },
                      ),
                      const Divider(height: 1), 
                      _MenuTile(
                        icon: Icons.upload_file,
                        title: 'My Notes',
                        subtitle: 'Manage uploaded notes',
                        onTap: () {
                          // Navigate to notes management
                        },
                      ),
                      const Divider(height: 1), 
                      _MenuTile(
                        icon: Icons.settings,
                        title: 'Settings',
                        subtitle: 'App preferences and settings',
                        onTap: () {
                          // Navigate to settings
                        },
                      ),
                    ],
                  ),
                ).animate()
                  .fadeIn(delay: 1000.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 32), 

                // Sign Out Button
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return CustomButton(
                        text: 'Sign Out',
                        onPressed: authProvider.isLoading ? null : () async {
                          await authProvider.signOut();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          }
                        },
                        isLoading: authProvider.isLoading,
                        backgroundColor: AppTheme.error,
                        prefixIcon: Icons.logout,
                      );
                    },
                  ),
                ).animate()
                  .fadeIn(delay: 1200.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 32), 
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8), 
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4), 
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withAlpha(26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryBlue,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppTheme.textSecondary,
      ),
      onTap: onTap,
    );
  }
}
