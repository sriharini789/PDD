import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/router.dart';
import '../../core/responsive.dart';
import '../../widgets/custom_button.dart';

class VerifySuccessScreen extends StatelessWidget {
  const VerifySuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ResponsiveLayout(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // Success Graphic
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                
                // Header
                Text(
                  'Email Verified!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Description
                Text(
                  'Your email has been successfully verified. You can now log in and access your Research AI system.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                    height: 1.5,
                  ),
                ),
                
                const Spacer(),
                
                // Button
                CustomButton(
                  text: 'Continue',
                  onPressed: () {
                    // Redirect to login page
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
