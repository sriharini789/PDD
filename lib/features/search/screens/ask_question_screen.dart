import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';
import '../../../core/router.dart';

class AskQuestionScreen extends StatelessWidget {
  const AskQuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ResponsiveLayout(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Ask Question'),
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
              Text(
                'What would you like to\nknow about your research?',
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.grey.shade200,
                  ),
                  boxShadow: isDark ? [] : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const TextField(
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Type your question here...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () => Navigator.pushNamed(context, AppRoutes.aiAnswer),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'Suggestions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),
              
              _buildSuggestionItem(context, 'Explain Transformer architecture in simple terms'),
              _buildSuggestionItem(context, 'Main findings of the BERT paper?'),
              _buildSuggestionItem(context, 'Recent trends in Generative AI for research'),
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

  Widget _buildSuggestionItem(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          side: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
          alignment: Alignment.centerLeft,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text, 
                style: TextStyle(
                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
