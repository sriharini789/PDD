import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';

class ExportOptionsScreen extends StatefulWidget {
  const ExportOptionsScreen({super.key});

  @override
  State<ExportOptionsScreen> createState() => _ExportOptionsScreenState();
}

class _ExportOptionsScreenState extends State<ExportOptionsScreen> {
  final Map<String, bool> _exportOptions = {
    'Export as PDF': true,
    'Export Summary': true,
    'Export Notes': false,
    'Export Citation': true,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ResponsiveLayout(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Export Paper'),
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
              const SizedBox(height: AppSpacing.md),
              Text(
                'Choose Export Options',
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Select the components you want to include in your export.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              Expanded(
                child: ListView(
                  children: _exportOptions.keys.map((option) {
                    final isSelected = _exportOptions[option]!;
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : (isDark ? Colors.white10 : Colors.grey.shade200),
                        ),
                      ),
                      child: CheckboxListTile(
                        title: Text(
                          option, 
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppColors.primary : null,
                          ),
                        ),
                        value: isSelected,
                        onChanged: (val) => setState(() => _exportOptions[option] = val!),
                        activeColor: AppColors.primary,
                        secondary: Icon(
                          _getIconForOption(option), 
                          color: isSelected ? AppColors.primary : Colors.grey,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppBorderRadius.md)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Processing export...'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('File exported successfully!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  });
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
                  'Export Now', 
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

  IconData _getIconForOption(String option) {
    if (option.contains('PDF')) return Icons.picture_as_pdf_rounded;
    if (option.contains('Summary')) return Icons.summarize_rounded;
    if (option.contains('Notes')) return Icons.edit_note_rounded;
    if (option.contains('Citation')) return Icons.format_quote_rounded;
    return Icons.file_present_rounded;
  }
}
