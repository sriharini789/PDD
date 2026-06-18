import 'package:flutter/material.dart';
import '../../../core/router.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';
import '../../../models/paper_model.dart';

class PaperDetailScreen extends StatelessWidget {
  const PaperDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final paper = ModalRoute.of(context)?.settings.arguments as PaperModel?;

    return ResponsiveLayout(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.more_vert_rounded),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.paperActions),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                paper?.title ?? 'Uploaded Paper',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                paper?.authors.isNotEmpty == true ? paper!.authors : 'Unknown Authors',
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              const Text(
                'Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                paper?.summary.isNotEmpty == true ? paper!.summary : 'No summary available.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? AppColors.textDarkSecondary 
                      : AppColors.textLightSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              const Text(
                'Topics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (paper?.topics != null && paper!.topics.isNotEmpty)
                    ? paper.topics.map((t) => _buildTopicChip(t)).toList()
                    : [
                        _buildTopicChip('Research'),
                        _buildTopicChip('Analysis'),
                      ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.paperFull, arguments: paper),
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
                    'Read Full Paper',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.chatPaper, arguments: paper),
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  label: const Text('Chat with AI Assistant'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
