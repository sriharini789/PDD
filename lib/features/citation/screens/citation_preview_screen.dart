import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';

class CitationPreviewScreen extends StatelessWidget {
  const CitationPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ResponsiveLayout(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Citation Preview'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'APA Citation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2C) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                ),
                child: Text(
                  'Vaswani, A., Shazeer, N., Parmar, N., Uszkoreit, J., Jones, L., Gomez, A. N., ... & Polosukhin, I. (2017). Attention is all you need. Advances in neural information processing systems, 30.',
                  style: TextStyle(
                    fontSize: 15, 
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                    color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Citation copied to clipboard')),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copy Citation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppBorderRadius.md)),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'Citation Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildDetailRow(context, 'Authors', 'Vaswani, A., Shazeer, N., et al.'),
              _buildDetailRow(context, 'Year', '2017'),
              _buildDetailRow(context, 'Title', 'Attention is all you need'),
              _buildDetailRow(context, 'Source', 'Advances in Neural Information Processing Systems'),
              _buildDetailRow(context, 'Volume', '30'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label, 
              style: TextStyle(
                color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary, 
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value, 
              style: TextStyle(
                fontWeight: FontWeight.w600, 
                fontSize: 14,
                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
