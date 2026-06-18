import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ResponsiveLayout(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('About App'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: AppColors.purpleGradient,
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome_rounded, size: 60, color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Research AI',
                style: TextStyle(
                  fontSize: 32, 
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Version 1.2.0',
                style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'Empowering researchers with context-aware citation assistance and AI-driven document understanding.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16, 
                  height: 1.6,
                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialIcon(Icons.language_rounded),
                  _buildSocialIcon(Icons.alternate_email_rounded),
                  _buildSocialIcon(Icons.share_rounded),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                '© 2024 Research AI Team. All rights reserved.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    );
  }
}
