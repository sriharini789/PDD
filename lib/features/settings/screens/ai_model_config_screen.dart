import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';

class AiModelConfigScreen extends StatefulWidget {
  const AiModelConfigScreen({super.key});

  @override
  State<AiModelConfigScreen> createState() => _AiModelConfigScreenState();
}

class _AiModelConfigScreenState extends State<AiModelConfigScreen> {
  String _selectedModel = 'GPT-4 Turbo';
  String _responseLength = 'Medium';
  double _temperature = 0.7;

  final List<String> _models = ['GPT-4 Turbo', 'GPT-3.5 Turbo', 'Claude 3 Opus', 'Gemini 1.5 Pro'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ResponsiveLayout(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('AI Model Settings'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Choose AI Model', 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                  border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedModel,
                    isExpanded: true,
                    dropdownColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                    items: _models.map((e) {
                      return DropdownMenuItem(
                        value: e, 
                        child: Text(e, style: const TextStyle(fontSize: 15)),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedModel = val!),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              const Text(
                'Response Length', 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  _buildLengthChip('Short'),
                  const SizedBox(width: 8),
                  _buildLengthChip('Medium'),
                  const SizedBox(width: 8),
                  _buildLengthChip('Long'),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Temperature', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _temperature.toStringAsFixed(1), 
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Slider(
                value: _temperature,
                min: 0,
                max: 1,
                divisions: 10,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.primary.withOpacity(0.1),
                onChanged: (val) => setState(() => _temperature = val),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Precise', 
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey : Colors.grey.shade600),
                  ),
                  Text(
                    'Creative', 
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey : Colors.grey.shade600),
                  ),
                ],
              ),
              
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('AI settings updated successfully'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    Navigator.pop(context);
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
                    'Save Settings', 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLengthChip(String label) {
    final isSelected = _responseLength == label;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: ChoiceChip(
        label: Center(
          child: Text(
            label, 
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primary : (isDark ? Colors.grey : Colors.grey.shade600),
            ),
          ),
        ),
        selected: isSelected,
        onSelected: (val) => setState(() => _responseLength = label),
        selectedColor: AppColors.primary.withOpacity(0.15),
        backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          side: BorderSide(color: isSelected ? AppColors.primary : Colors.transparent),
        ),
        showCheckmark: false,
      ),
    );
  }
}
