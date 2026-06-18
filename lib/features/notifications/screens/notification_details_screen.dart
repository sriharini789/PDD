import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';
import '../../../core/router.dart';

class NotificationDetailsScreen extends StatelessWidget {
  const NotificationDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ResponsiveLayout(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Notification'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.delete_outline_rounded), onPressed: () {}),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 32),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Citation Suggestion',
                          style: TextStyle(
                            fontSize: 14, 
                            color: AppColors.primary, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'New papers found!',
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'Oct 24, 2023 • 10:30 AM',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'We found 2 new papers that might be relevant to your research question: "What are the recent trends in Generative AI for research?".',
                style: TextStyle(
                  fontSize: 15, 
                  height: 1.6,
                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildPaperHint('Large Language Models in Research: A Survey', '2023'),
                    const Divider(height: 24),
                    _buildPaperHint('AI-Driven Literature Reviews', '2024'),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.searchResults),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'View Suggested Papers', 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaperHint(String title, String year) {
    return Row(
      children: [
        const Icon(Icons.description_outlined, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, 
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(year, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
      ],
    );
  }
}
