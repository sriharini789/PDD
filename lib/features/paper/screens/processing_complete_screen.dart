import 'package:flutter/material.dart';
import '../../../core/router.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';

class ProcessingCompleteScreen extends StatelessWidget {
  const ProcessingCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 100,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'Processing Complete!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Your paper has been analyzed successfully and is ready for exploration.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final paper = ModalRoute.of(context)?.settings.arguments;
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.paperDetail,
                      arguments: paper,
                    );
                  },
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
                    'View Paper',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
