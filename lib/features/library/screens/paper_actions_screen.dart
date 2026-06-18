import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';
import '../../../core/router.dart';

class PaperActionsScreen extends StatelessWidget {
  const PaperActionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ResponsiveLayout(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Paper Actions'),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              _buildPaperHeader(context),
              const SizedBox(height: AppSpacing.xl),
              _buildActionItem(context, 'View Details', Icons.info_outline_rounded, AppRoutes.paperDetail),
              _buildActionItem(context, 'Chat with Paper', Icons.chat_bubble_outline_rounded, AppRoutes.chatPaper),
              _buildActionItem(context, 'Add to Favorites', Icons.favorite_border_rounded, null),
              _buildActionItem(context, 'Cite Paper', Icons.format_quote_rounded, AppRoutes.citationGenerator),
              _buildActionItem(context, 'Notes & Highlights', Icons.edit_note_rounded, AppRoutes.notes),
              _buildActionItem(context, 'Export', Icons.ios_share_rounded, AppRoutes.exportOptions),
              const Divider(height: AppSpacing.xl),
              _buildActionItem(context, 'Delete', Icons.delete_outline_rounded, null, isDestructive: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaperHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: const Icon(Icons.description_rounded, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attention Is All You Need',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'A. Vaswani et al., 2017',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    String title,
    IconData icon,
    String? route, {
    bool isDestructive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDestructive ? AppColors.error : (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary);
    
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      trailing: isDestructive ? null : const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
      onTap: () {
        if (route != null) {
          Navigator.pushNamed(context, route);
        } else {
          Navigator.pop(context);
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppBorderRadius.sm)),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
    );
  }
}
