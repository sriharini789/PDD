import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';

class AiAnswerScreen extends StatelessWidget {
  const AiAnswerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ResponsiveLayout(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('AI Answer'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
            IconButton(icon: const Icon(Icons.bookmark_border_rounded), onPressed: () {}),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.help_outline_rounded, color: AppColors.primary, size: 22),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'What is the Transformer model?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                        boxShadow: isDark ? [] : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                child: const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.primary),
                              ),
                              const SizedBox(width: 10),
                              const Text('AI Assistant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'The Transformer is a deep learning model architecture introduced in 2017, primarily used in the field of natural language processing (NLP). It is designed to handle sequential data, such as natural language, but unlike recurrent neural networks (RNNs), Transformers do not require the sequential data to be processed in order.\n\nKey features include:\n• Self-attention mechanisms\n• Multi-head attention\n• Positional encoding\n• Parallel processing capabilities',
                            style: TextStyle(
                              fontSize: 15, 
                              height: 1.6,
                              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            children: [
                              _buildActionButton(Icons.thumb_up_alt_outlined),
                              _buildActionButton(Icons.thumb_down_alt_outlined),
                              const Spacer(),
                              _buildActionButton(Icons.copy_rounded, label: 'Copy'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.xl),
                    const Text(
                      'Sources',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildSourceItem(context, 'Attention Is All You Need (2017)'),
                    _buildSourceItem(context, 'BERT: Pre-training of Deep Bidirectional Transformers'),
                  ],
                ),
              ),
            ),
            _buildFollowUpArea(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, {String? label}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: TextButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 18, color: Colors.grey),
        label: label != null ? Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)) : const SizedBox.shrink(),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  Widget _buildSourceItem(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              title, 
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildFollowUpArea(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Ask follow-up...',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF12121A) : Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
