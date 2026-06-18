import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/router.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';
import '../../../core/auth_service.dart';
import '../../../models/paper_model.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _startProcessing();
  }

  void _startProcessing() {
    // We poll the backend for the paper's real-time status
    Future.microtask(() {
      if (!mounted) return;
      final paper = ModalRoute.of(context)?.settings.arguments as PaperModel?;
      if (paper == null) {
        // Fallback for mocked transitions if no paper is provided
        _simulateMockProgress();
        return;
      }
      _pollStatus(paper.id);
    });
  }

  void _simulateMockProgress() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _currentStep = 1);
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() => _currentStep = 2);
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          setState(() => _currentStep = 3);
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.processingComplete);
          });
        });
      });
    });
  }

  bool _hasError = false;

  void _pollStatus(int paperId) async {
    if (_hasError) return;
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5001/api/papers/$paperId'),
        headers: {
          if (authService.token != null) 'Authorization': 'Bearer ${authService.token}',
        },
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['paper'] != null) {
          final updatedPaper = PaperModel.fromJson(data['paper']);
          
          setState(() {
            if (updatedPaper.processingStage == 'extracting') {
              _currentStep = 0;
            } else if (updatedPaper.processingStage == 'analyzing') {
              _currentStep = 1;
            } else if (updatedPaper.processingStage == 'embedding') {
              _currentStep = 2;
            } else if (updatedPaper.processingStage == 'done' || updatedPaper.status == 'completed') {
              _currentStep = 3;
            }
          });

          if (updatedPaper.status == 'completed') {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.processingComplete,
                  arguments: updatedPaper,
                );
              }
            });
            return;
          } else if (updatedPaper.status == 'failed') {
            setState(() {
              _hasError = true;
            });
            return;
          }
        }
      }
    } catch (e) {
      print('Polling error: $e');
    }

    // Poll again in 2 seconds if not failed
    if (!_hasError) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _pollStatus(paperId);
      });
    }
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
              Center(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: const CircularProgressIndicator(
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'Analyzing Research Paper',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Extracting metadata, sections, and generating citations.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: AppSpacing.xxl),
              
              if (true) ...[
                _buildStepItem('Extracting Text', _currentStep > 0, _currentStep == 0),
                _buildStepItem('Analyzing Sections', _currentStep > 1, _currentStep == 1),
                _buildStepItem('Generating Citations', _currentStep > 2, _currentStep == 2),
              ],
              
              const Spacer(),
              
              if (_hasError) ...[
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                      _currentStep = 0;
                    });
                    _startProcessing();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Retry Analysis'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    final paper = ModalRoute.of(context)?.settings.arguments;
                    Navigator.pushReplacementNamed(
                      context, 
                      AppRoutes.processingComplete,
                      arguments: paper,
                    );
                  },
                  child: const Text('Skip and View Paper anyway'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem(String title, bool isDone, bool isInProgress) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.lg),
      child: Row(
        children: [
          if (isDone)
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28)
          else if (isInProgress)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)),
            )
          else
            Icon(Icons.radio_button_unchecked_rounded, color: Colors.grey.shade400, size: 28),
          
          const SizedBox(width: AppSpacing.md),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isDone || isInProgress ? FontWeight.w600 : FontWeight.normal,
              color: isDone 
                  ? (Theme.of(context).brightness == Brightness.dark ? AppColors.textDarkPrimary : AppColors.textLightPrimary) 
                  : (isInProgress ? AppColors.primary : Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
