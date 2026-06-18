import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';

class AdvancedFiltersScreen extends StatefulWidget {
  const AdvancedFiltersScreen({super.key});

  @override
  State<AdvancedFiltersScreen> createState() => _AdvancedFiltersScreenState();
}

class _AdvancedFiltersScreenState extends State<AdvancedFiltersScreen> {
  RangeValues _yearRange = const RangeValues(2015, 2024);
  final List<String> _selectedTypes = ['Journal', 'Conference'];
  String _sortBy = 'Relevance';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ResponsiveLayout(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Filters'),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _yearRange = const RangeValues(2010, 2024);
                  _sortBy = 'Relevance';
                });
              },
              child: const Text('Reset'),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Year Range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: AppSpacing.sm),
              RangeSlider(
                values: _yearRange,
                min: 2000,
                max: 2024,
                divisions: 24,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.primary.withOpacity(0.1),
                labels: RangeLabels(
                  _yearRange.start.round().toString(),
                  _yearRange.end.round().toString(),
                ),
                onChanged: (val) => setState(() => _yearRange = val),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_yearRange.start.round().toString(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(_yearRange.end.round().toString(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              
              const Text('Document Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTypeChip('Journal'),
                  _buildTypeChip('Conference'),
                  _buildTypeChip('Preprint'),
                  _buildTypeChip('Book'),
                  _buildTypeChip('Thesis'),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              
              const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: AppSpacing.md),
              _buildSortOption('Relevance'),
              _buildSortOption('Newest First'),
              _buildSortOption('Most Cited'),
              _buildSortOption('A-Z'),
              
              const Spacer(),
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
                  child: const Text('Apply Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label) {
    final isSelected = _selectedTypes.contains(label);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        setState(() {
          if (val) {
            _selectedTypes.add(label);
          } else {
            _selectedTypes.remove(label);
          }
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.grey.shade100,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        side: BorderSide(color: isSelected ? AppColors.primary : Colors.transparent),
      ),
    );
  }

  Widget _buildSortOption(String label) {
    final isSelected = _sortBy == label;
    return InkWell(
      onTap: () => setState(() => _sortBy = label),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade400,
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label, 
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? AppColors.primary : null,
                fontWeight: isSelected ? FontWeight.w600 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
