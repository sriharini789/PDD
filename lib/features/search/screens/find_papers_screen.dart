import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';
import '../../../core/router.dart';

class FindPapersScreen extends StatelessWidget {
  const FindPapersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ResponsiveLayout(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Find Papers'),
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
                'Find Relevant Papers',
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search papers, authors, topics...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E1E2C) : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => Navigator.pushNamed(context, AppRoutes.searchResults),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filters', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.advancedFilters),
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              
              Row(
                children: [
                  Expanded(child: _buildFilterDropdown(context, 'Year', '2023')),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _buildFilterDropdown(context, 'Relevance', 'High')),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _buildFilterDropdown(context, 'Document Type', 'Journal Article'),
              
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.searchResults),
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
                  'Search Papers', 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 2,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
          backgroundColor: Theme.of(context).cardTheme.color,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.library_books_rounded), label: 'Library'),
            BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
          onTap: (index) {
            if (index == 0) Navigator.pushNamed(context, AppRoutes.dashboard);
            if (index == 1) Navigator.pushNamed(context, AppRoutes.library);
            if (index == 3) Navigator.pushNamed(context, AppRoutes.settings);
          },
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}
