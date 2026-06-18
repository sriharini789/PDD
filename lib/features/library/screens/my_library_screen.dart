import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';
import '../../../core/router.dart';

class MyLibraryScreen extends StatelessWidget {
  const MyLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ResponsiveLayout(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('My Library'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.uploadPaper),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _buildCategoryItem(context, 'All Papers', Icons.description_rounded, 25, AppRoutes.libraryPapers),
            _buildCategoryItem(context, 'Favorites', Icons.favorite_rounded, 8, AppRoutes.favorites),
            _buildCategoryItem(context, 'Recently Read', Icons.history_rounded, 10, AppRoutes.libraryPapers),
            _buildCategoryItem(context, 'My Uploads', Icons.cloud_done_rounded, 15, AppRoutes.libraryPapers),
            _buildCategoryItem(context, 'Reading List', Icons.bookmark_rounded, 5, AppRoutes.readingList),
            _buildCategoryItem(context, 'Trash', Icons.delete_rounded, 2, AppRoutes.libraryPapers),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
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
            if (index == 2) Navigator.pushNamed(context, AppRoutes.findPapers);
            if (index == 3) Navigator.pushNamed(context, AppRoutes.settings);
          },
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String title,
    IconData icon,
    int count,
    String route,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title, 
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count', 
                style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
          ],
        ),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
