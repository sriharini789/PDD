import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';
import '../../../core/router.dart';
import '../../../providers/auth_provider.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userName = user?['fullName'] ?? 'Alex Johnson';
    final userEmail = user?['email'] ?? 'alex.j@example.com';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ResponsiveLayout(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Profile'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_rounded, size: 20),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.createProfile,
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 4,
                      ),
                    ),
                    child: FutureBuilder<String?>(
                      future: SharedPreferences.getInstance().then(
                            (prefs) => prefs.getString('profile_image'),
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasData &&
                            snapshot.data != null &&
                            snapshot.data!.isNotEmpty) {
                          return CircleAvatar(
                            radius: 60,
                            backgroundImage: MemoryImage(
                              base64Decode(snapshot.data!),
                            ),
                          );
                        }

                        return const CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.primaryLight,
                          child: Icon(
                            Icons.person_rounded,
                            size: 70,
                            color: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              Text(
                userName,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textDarkPrimary
                      : AppColors.textLightPrimary,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                userEmail,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              _buildProfileOption(
                context,
                'Edit Profile',
                Icons.person_outline_rounded,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.createProfile,
                ),
              ),

              _buildProfileOption(
                context,
                'Change Password',
                Icons.lock_outline_rounded,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.forgotPassword,
                ),
              ),

              _buildProfileOption(
                context,
                'Privacy Settings',
                Icons.security_rounded,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.privacySettings,
                ),
              ),

              _buildProfileOption(
                context,
                'Notification Preferences',
                Icons.notifications_none_rounded,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.notifications,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              Divider(
                color: isDark
                    ? Colors.white10
                    : Colors.grey.shade200,
              ),

              const SizedBox(height: AppSpacing.md),

              _buildProfileOption(
                context,
                'Logout',
                Icons.logout_rounded,
                isDestructive: true,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.logoutConfirm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(
      BuildContext context,
      String title,
      IconData icon, {
        bool isDestructive = false,
        VoidCallback? onTap,
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final color = isDestructive
        ? AppColors.error
        : (isDark
        ? AppColors.textDarkPrimary
        : AppColors.textLightPrimary);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.error.withOpacity(0.1)
              : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive
              ? AppColors.error
              : AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: color,
        ),
      ),
      trailing: isDestructive
          ? null
          : const Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}