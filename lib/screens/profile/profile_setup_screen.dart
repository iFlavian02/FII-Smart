import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int? _selectedYear;
  int? _selectedSemester;
  String? _selectedCourse;

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  void _loadCurrentData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _selectedYear = user.yearOfStudy;
      _selectedSemester = user.semester;
      _selectedCourse = user.selectedCourse;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedYear == null || _selectedSemester == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your year of study and semester'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.updateUserProfile(
        displayName: _nameController.text.trim().isNotEmpty 
            ? _nameController.text.trim() 
            : null,
        yearOfStudy: _selectedYear,
        semester: _selectedSemester,
        selectedCourse: _selectedCourse,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final courses = _selectedYear != null 
        ? userProvider.getCoursesForYear(_selectedYear!)
        : <String>[];

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
                    if (Navigator.canPop(context))
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ).animate()
                        .fadeIn(duration: 600.ms)
                        .slideX(begin: -0.3, end: 0),
                    Expanded(
                      child: Text(
                        'Complete Your Profile',
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
                  'Help us personalize your learning experience',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withAlpha(230),
                  ),
                ).animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 40),

                // Form
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Name Field
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Display Name (Optional)',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ).animate()
                          .fadeIn(delay: 600.ms, duration: 600.ms)
                          .slideX(begin: -0.3, end: 0),

                        const SizedBox(height: 24),

                        // Year of Study
                        Text(
                          'Year of Study *',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ).animate()
                          .fadeIn(delay: 700.ms, duration: 600.ms)
                          .slideX(begin: -0.3, end: 0),

                        const SizedBox(height: 12),

                        Row(
                          children: [1, 2, 3].map((year) {
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: year != 3 ? 8 : 0,
                                ),
                                child: _YearButton(
                                  year: year,
                                  isSelected: _selectedYear == year,
                                  onTap: () {
                                    setState(() {
                                      _selectedYear = year;
                                      _selectedCourse = null; // Reset course selection
                                    });
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ).animate()
                          .fadeIn(delay: 800.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),

                        const SizedBox(height: 24),

                        // Semester
                        Text(
                          'Current Semester *',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ).animate()
                          .fadeIn(delay: 900.ms, duration: 600.ms)
                          .slideX(begin: -0.3, end: 0),

                        const SizedBox(height: 12),

                        Row(
                          children: [1, 2].map((semester) {
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: semester != 2 ? 8 : 0,
                                ),
                                child: _SemesterButton(
                                  semester: semester,
                                  isSelected: _selectedSemester == semester,
                                  onTap: () {
                                    setState(() {
                                      _selectedSemester = semester;
                                    });
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ).animate()
                          .fadeIn(delay: 1000.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),

                        const SizedBox(height: 24),

                        // Course Selection
                        if (courses.isNotEmpty) ...[
                          Text(
                            'Primary Course Focus',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ).animate()
                            .fadeIn(delay: 1100.ms, duration: 600.ms)
                            .slideX(begin: -0.3, end: 0),

                          const SizedBox(height: 12),

                          DropdownButtonFormField<String>(
                            initialValue: _selectedCourse,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.book_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            hint: const Text('Select a course'),
                            items: courses.map((course) {
                              return DropdownMenuItem(
                                value: course,
                                child: Text(course),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCourse = value;
                              });
                            },
                          ).animate()
                            .fadeIn(delay: 1200.ms, duration: 600.ms)
                            .slideY(begin: 0.3, end: 0),

                          const SizedBox(height: 32),
                        ],

                        // Save Button
                        Consumer<UserProvider>(
                          builder: (context, userProvider, child) {
                            return CustomButton(
                              text: 'Save Profile',
                              onPressed: userProvider.isLoading ? null : _saveProfile,
                              isLoading: userProvider.isLoading,
                            );
                          },
                        ).animate()
                          .fadeIn(delay: 1300.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),
                      ],
                    ),
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
}

class _YearButton extends StatelessWidget {
  final int year;
  final bool isSelected;
  final VoidCallback onTap;

  const _YearButton({
    required this.year,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Year $year',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              year == 1 ? 'Freshman' : year == 2 ? 'Sophomore' : 'Junior',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? Colors.white.withAlpha(230) : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SemesterButton extends StatelessWidget {
  final int semester;
  final bool isSelected;
  final VoidCallback onTap;

  const _SemesterButton({
    required this.semester,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.secondaryTeal : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.secondaryTeal : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Semester $semester',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              semester == 1 ? 'Fall/Spring' : 'Spring/Fall',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? Colors.white.withAlpha(230) : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}