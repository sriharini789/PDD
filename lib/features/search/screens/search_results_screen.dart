import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';
import '../../../core/router.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ResponsiveLayout(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Search Results'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.tune_rounded),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.advancedFilters),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: TextField(
                controller: TextEditingController(text: 'Transformer Model'),
                decoration: InputDecoration(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Found 124 relevant papers',
                  style: TextStyle(
                    color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary, 
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                children: [
                  _buildResultCard(
                    context,
                    title: 'Attention Is All You Need',
                    authors: 'A. Vaswani et al., 2017',
                    snippet: 'We propose a new simple network architecture, the Transformer, based solely on attention mechanisms...',
                  ),
                  _buildResultCard(
                    context,
                    title: 'BERT: Pre-training of Deep Bidirectional Transformers',
                    authors: 'Devlin, J. et al., 2018',
                    snippet: 'We introduce a new language representation model called BERT, which stands for Bidirectional Encoder Representations...',
                  ),
                  _buildResultCard(
                    context,
                    title: 'The Illustrated Transformer',
                    authors: 'Jay Alammar, 2018',
                    snippet: 'In this post, we will look at the Transformer – a model that uses attention to boost the speed with which...',
                  ),
                  _buildResultCard(
                    context,
                    title: 'Generating Long Sequences with Sparse Transformers',
                    authors: 'R. Child et al., 2019',
                    snippet: 'Transformers are powerful models for sequence modeling, but their memory and computational requirements...',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(
    BuildContext context, {
    required String title,
    required String authors,
    required String snippet,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Icon(
                  Icons.bookmark_border_rounded, 
                  color: isDark ? AppColors.primaryDarkAccent : AppColors.primary,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              authors, 
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              snippet,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13, 
                height: 1.4,
                color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTag('Deep Learning'),
                const SizedBox(width: 8),
                _buildTag('NLP'),
                const Spacer(),
                InkWell(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.paperDetail),
                  child: const Text(
                    'View Details',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
