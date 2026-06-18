import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ResponsiveLayout(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Terms & Conditions'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last updated: October 2023',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'By using Research AI, you agree to our Terms of Service and Privacy Policy.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 16,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _buildSection('1. Use of Service', 'You agree to use this app for lawful research purposes only. You must not upload any copyrighted material that you do not have rights to use. The AI insights provided are for assistance and should be verified by the researcher.'),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSection('2. Data Privacy', 'We collect data to improve our AI models. Your personal information is encrypted and stored securely. We do not sell your research data to third parties without explicit consent.'),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSection('3. AI Disclaimer', 'Research AI uses generative models. While we strive for accuracy, the summaries and citations generated may occasionally contain errors. Always refer back to the original source text.'),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSection('4. Account Security', 'You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.'),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppBorderRadius.md),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('I Agree', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          content,
          style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.grey),
        ),
      ],
    );
  }
}
