import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/router.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';
import '../../../providers/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userName = user?['fullName'] ?? 'Alex';

    return ResponsiveLayout(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: AppSpacing.md),
            child: FutureBuilder<String?>(
              future: SharedPreferences.getInstance()
                  .then((prefs) => prefs.getString('profile_image')),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return CircleAvatar(
                    backgroundImage: MemoryImage(
                      base64Decode(snapshot.data!),
                    ),
                  );
                }

                return const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(
                    Icons.person,
                    color: AppColors.primary,
                  ),
                );
              },
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: IconButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
                icon: const Icon(Icons.notifications_none_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).cardTheme.color,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning, $userName!',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'What would you like to do today?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.1,
                children: [
                  _buildActionCard(
                    context,
                    title: 'Upload Paper',
                    icon: Icons.upload_file_rounded,
                    color: AppColors.primary,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.uploadPaper),
                  ),
                  _buildActionCard(
                    context,
                    title: 'Ask Question',
                    icon: Icons.chat_bubble_outline_rounded,
                    color: const Color(0xFFFF9800),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.askQuestion),
                  ),
                  _buildActionCard(
                    context,
                    title: 'Find Papers',
                    icon: Icons.search_rounded,
                    color: const Color(0xFF4CAF50),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.findPapers),
                  ),
                  _buildActionCard(
                    context,
                    title: 'My Library',
                    icon: Icons.book_rounded,
                    color: const Color(0xFF2196F3),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.library),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Papers',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.libraryPapers),
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              
              _buildRecentPaperItem(
                context,
                title: 'Attention Is All You Need',
                authors: 'A. Vaswani et al., 2017',
                onTap: () => Navigator.pushNamed(context, AppRoutes.paperDetail),
              ),
              _buildRecentPaperItem(
                context,
                title: 'BERT: Pre-training of Deep Bidirectional Transformers',
                authors: 'Devlin, J. et al., 2018',
                onTap: () => Navigator.pushNamed(context, AppRoutes.paperDetail),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Theme.of(context).brightness == Brightness.dark 
              ? AppColors.textDarkSecondary 
              : AppColors.textLightSecondary,
          backgroundColor: Theme.of(context).cardTheme.color,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.library_books_rounded), label: 'Library'),
            BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
          onTap: (index) {
            if (index == 1) Navigator.pushNamed(context, AppRoutes.library);
            if (index == 2) Navigator.pushNamed(context, AppRoutes.findPapers);
            if (index == 3) Navigator.pushNamed(context, AppRoutes.settings);
          },
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppBorderRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? color.withOpacity(0.15) : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          border: Border.all(
            color: isDark ? color.withOpacity(0.3) : color.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isDark ? color.withOpacity(0.2) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: isDark ? [] : [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPaperItem(
    BuildContext context, {
    required String title,
    required String authors,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white10
              : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          child: const Icon(Icons.description_rounded, color: AppColors.primary),
        ),
        title: Text(
          title, 
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          authors,
          style: const TextStyle(fontSize: 13),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20),
        onTap: onTap,
      ),
    );
  }
}
