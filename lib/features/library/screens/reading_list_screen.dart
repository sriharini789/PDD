import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';

class ReadingListScreen extends StatelessWidget {
  const ReadingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ResponsiveLayout(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Reading List'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.add_rounded), onPressed: () {}),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const SizedBox(height: AppSpacing.md),
            _buildStatusCard(context, 'To Read', 9, Icons.bookmark_border_rounded, Colors.orange),
            _buildStatusCard(context, 'Reading', 3, Icons.menu_book_rounded, Colors.blue),
            _buildStatusCard(context, 'Completed', 15, Icons.check_circle_outline_rounded, Colors.green),
            
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'Recent in List',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildRecentListItem(context, 'Attention Is All You Need', 'Reading'),
            _buildRecentListItem(context, 'BERT Analysis', 'To Read'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, String title, int count, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count', 
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildRecentListItem(BuildContext context, String title, String status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Text(status, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20),
        onTap: () {},
      ),
    );
  }
}
