import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';
import '../../../core/router.dart';

class CitationGeneratorScreen extends StatefulWidget {
  const CitationGeneratorScreen({super.key});

  @override
  State<CitationGeneratorScreen> createState() => _CitationGeneratorScreenState();
}

class _CitationGeneratorScreenState extends State<CitationGeneratorScreen> {
  String _selectedFormat = 'APA';

  final List<String> _formats = [
    'APA',
    'MLA',
    'IEEE',
    'Chicago',
    'Harvard',
    'BibTeX',
    'Vancouver',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ResponsiveLayout(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Cite Paper'),
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
                'Select Citation Format',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: ListView.builder(
                  itemCount: _formats.length,
                  itemBuilder: (context, index) {
                    final format = _formats[index];
                    final isSelected = _selectedFormat == format;
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : (isDark ? Colors.white12 : Colors.grey.shade200),
                        ),
                      ),
                      child: RadioListTile<String>(
                        title: Text(
                          format, 
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppColors.primary : null,
                          ),
                        ),
                        value: format,
                        groupValue: _selectedFormat,
                        onChanged: (val) => setState(() => _selectedFormat = val!),
                        activeColor: AppColors.primary,
                        controlAffinity: ListTileControlAffinity.trailing,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppBorderRadius.md)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.citationGenerated),
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
                  'Copy Citation', 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
