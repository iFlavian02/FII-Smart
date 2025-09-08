import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class RecentQuizCard extends StatelessWidget {
  final String title;
  final int score;
  final int totalQuestions;
  final DateTime completedAt;

  const RecentQuizCard({
    super.key,
    required this.title,
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (score / totalQuestions * 100).round();
    final timeAgo = _formatTimeAgo(completedAt);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getScoreColor(percentage).withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.quiz,
                color: _getScoreColor(percentage),
                size: 24,
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
                    '$score/$totalQuestions correct • $timeAgo',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getScoreColor(percentage).withAlpha(26),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$percentage%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _getScoreColor(percentage),
                  fontWeight: FontWeight.w600,
                ),
              ),
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
}