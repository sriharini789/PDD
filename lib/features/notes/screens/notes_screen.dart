import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';
import '../../../core/router.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ResponsiveLayout(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Notes & Highlights'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E1E2C) : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                children: [
                  _buildNoteCard(
                    context,
                    text: 'Key contribution of the Transformer model is dispensing with recurrence and convolutions.',
                    color: const Color(0xFFFFF9C4), // Light Yellow
                    date: 'Oct 12, 2023',
                  ),
                  _buildNoteCard(
                    context,
                    text: 'Self-attention mechanism allow the model to weight the significance of each part of the input data.',
                    color: const Color(0xFFE3F2FD), // Light Blue
                    date: 'Oct 14, 2023',
                  ),
                  _buildNoteCard(
                    context,
                    text: 'Multi-head attention allows the model to jointly attend to information from different representation subspaces.',
                    color: const Color(0xFFFCE4EC), // Light Pink
                    date: 'Oct 15, 2023',
                  ),
                  _buildNoteCard(
                    context,
                    text: 'The model achieves a new state of the art on English-to-German and English-to-French translation tasks.',
                    color: const Color(0xFFE8F5E9), // Light Green
                    date: 'Oct 16, 2023',
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.addNote),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildNoteCard(
    BuildContext context, {
    required String text,
    required Color color,
    required String date,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? color.withOpacity(0.2) : color,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: isDark ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        side: BorderSide(color: isDark ? color.withOpacity(0.5) : Colors.transparent),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 14, 
                height: 1.5, 
                color: isDark ? AppColors.textDarkPrimary : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date, 
                  style: TextStyle(
                    fontSize: 11, 
                    color: isDark ? Colors.grey : Colors.grey.shade700,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 16, color: isDark ? Colors.grey : Colors.grey.shade600),
                    const SizedBox(width: 12),
                    Icon(Icons.delete_outline_rounded, size: 16, color: isDark ? Colors.grey : Colors.grey.shade600),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
