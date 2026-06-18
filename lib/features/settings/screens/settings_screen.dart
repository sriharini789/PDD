import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkGlobal = Theme.of(context).brightness == Brightness.dark;
    return ResponsiveLayout(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Settings'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          children: [
            const SizedBox(height: AppSpacing.md),
            _buildSettingsSection(context, 'General', [
              _buildSettingsItem(context, 'Account', Icons.person_outline_rounded, AppRoutes.userProfile),
              _buildSettingsItem(context, 'Preferences', Icons.tune_rounded, null),
            ]),
            const SizedBox(height: AppSpacing.lg),
            _buildSettingsSection(context, 'AI & Privacy', [
              _buildSettingsItem(context, 'AI Model Settings', Icons.auto_awesome_outlined, AppRoutes.aiModelConfig),
              _buildSettingsItem(context, 'Privacy & Security', Icons.lock_outline_rounded, AppRoutes.privacySettings),
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeController,
                builder: (context, mode, _) {
                  final isDark = mode == ThemeMode.dark;
                  return _buildSettingsToggle(
                    context, 
                    'Dark Mode', 
                    Icons.dark_mode_outlined, 
                    isDark, 
                    (val) => themeController.toggleTheme(val)
                  );
                },
              ),
            ]),
            const SizedBox(height: AppSpacing.lg),
            _buildSettingsSection(context, 'Support', [
              _buildSettingsItem(context, 'Help Center', Icons.help_outline_rounded, AppRoutes.helpCenter),
              _buildSettingsItem(context, 'About Research AI', Icons.info_outline_rounded, AppRoutes.about),
              _buildSettingsItem(context, 'Terms & Conditions', Icons.description_outlined, AppRoutes.terms),
            ]),
            const SizedBox(height: AppSpacing.xl),
            _buildSettingsItem(
              context, 
              'Logout', 
              Icons.logout_rounded, 
              AppRoutes.logoutConfirm, 
              isDestructive: true
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 3,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: isDarkGlobal ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
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
            if (index == 2) Navigator.pushNamed(context, AppRoutes.findPapers);
          },
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.sm),
          child: Text(
            title, 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade200,
            ),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    String title,
    IconData icon,
    String? route, {
    bool isDestructive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDestructive ? AppColors.error : (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary);
    
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      trailing: isDestructive ? null : const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
      onTap: () {
        if (route != null) Navigator.pushNamed(context, route);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppBorderRadius.md)),
    );
  }

  Widget _buildSettingsToggle(
    BuildContext context,
    String title,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}
