import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';
import '../../../core/router.dart';

class LibraryPapersScreen extends StatelessWidget {
  const LibraryPapersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ResponsiveLayout(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('All Papers'),
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
                  hintText: 'Search in library...',
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
                  _buildPaperItem(context, 'Attention Is All You Need', 'A. Vaswani et al., 2017'),
                  _buildPaperItem(context, 'BERT: Pre-training of Deep Bidirectional...', 'Devlin, J. et al., 2018'),
                  _buildPaperItem(context, 'GPT-3: Language Models are Few-Shot Learners', 'Brown, T. et al., 2020'),
                  _buildPaperItem(context, 'The Illustrated Transformer', 'Jay Alammar, 2018'),
                  _buildPaperItem(context, 'ImageNet Classification with Deep CNNs', 'Krizhevsky, A. et al., 2012'),
                  _buildPaperItem(context, 'ResNet: Deep Residual Learning for Image...', 'He, K. et al., 2015'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaperItem(BuildContext context, String title, String authors) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          child: const Icon(Icons.description_rounded, color: AppColors.primary),
        ),
        title: Text(
          title, 
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          authors, 
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.grey, size: 20),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.paperActions),
        ),
        onTap: () => Navigator.pushNamed(context, AppRoutes.paperDetail),
      ),
    );
  }
}
