import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';
import '../../../core/router.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ResponsiveLayout(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Notifications'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.done_all_rounded, size: 20),
              onPressed: () {},
              tooltip: 'Mark all as read',
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const Text(
              'Today', 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildNotificationItem(
              context,
              'Paper processing complete',
              'Your paper "Attention Is All You Need" has been analyzed successfully.',
              '2m ago',
              Icons.check_circle_rounded,
              AppColors.success,
              isUnread: true,
            ),
            _buildNotificationItem(
              context,
              'New citation suggestion',
              'We found 3 new papers that might be relevant to your research on Transformers.',
              '1h ago',
              Icons.auto_awesome_rounded,
              AppColors.primary,
              isUnread: true,
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'Yesterday', 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildNotificationItem(
              context,
              'Weekly research digest',
              'Your weekly summary of research trends is ready to view.',
              '1d ago',
              Icons.description_rounded,
              Colors.blue,
              isUnread: false,
            ),
            _buildNotificationItem(
              context,
              'Library update',
              'System maintenance scheduled for tonight at 12:00 AM.',
              '1d ago',
              Icons.info_rounded,
              Colors.orange,
              isUnread: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    String title,
    String body,
    String time,
    IconData icon,
    Color iconColor, {
    required bool isUnread,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isUnread 
            ? iconColor.withOpacity(isDark ? 0.1 : 0.05) 
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
        leading: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            if (isUnread)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          title, 
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.w600, 
            fontSize: 14,
            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              body, 
              style: TextStyle(
                fontSize: 12, 
                color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time, 
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        onTap: () => Navigator.pushNamed(context, AppRoutes.notificationDetails),
      ),
    );
  }
}
