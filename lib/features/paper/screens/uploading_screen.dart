import 'package:flutter/material.dart';
import '../../../core/router.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';

class UploadingScreen extends StatefulWidget {
  const UploadingScreen({super.key});

  @override
  State<UploadingScreen> createState() => _UploadingScreenState();
}

class _UploadingScreenState extends State<UploadingScreen> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _simulateProgress();
  }

  void _simulateProgress() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      setState(() {
        _progress += 0.05;
        if (_progress < 1.0) {
          _simulateProgress();
        } else {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              final paper = ModalRoute.of(context)?.settings.arguments;
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.processing,
                arguments: paper,
              );
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              const Icon(
                Icons.upload_file_rounded,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'Uploading Paper...',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Please wait while we process your file',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl * 1.5),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      child: LinearProgressIndicator(
                        value: _progress,
                        minHeight: 12,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '${(_progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel Upload',
                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
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
