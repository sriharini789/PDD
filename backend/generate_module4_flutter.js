const fs = require('fs');
const path = require('path');

const libDir = path.join(__dirname, '..', 'lib');
const dirsToCreate = [
  'models',
  'providers',
  'features/notifications/screens',
  'features/settings/screens',
  'features/support/screens',
  'features/auth/screens', // for logout
];

dirsToCreate.forEach(dir => {
  const fullPath = path.join(libDir, dir);
  if (!fs.existsSync(fullPath)) {
    fs.mkdirSync(fullPath, { recursive: true });
  }
});

const files = {
  'models/notification_model.dart': `
class NotificationModel {
  final int id;
  final String title;
  final String message;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
  });
}
`,
  'models/settings_model.dart': `
class SettingsModel {
  final bool darkMode;
  final String aiModel;
  final bool privacyTelemetry;

  SettingsModel({
    required this.darkMode,
    required this.aiModel,
    required this.privacyTelemetry,
  });
}
`,
  'providers/notification_provider.dart': `
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';

class NotificationNotifier extends AsyncNotifier<List<NotificationModel>> {
  @override
  Future<List<NotificationModel>> build() async {
    return [
      NotificationModel(id: 1, title: 'Welcome', message: 'Welcome to Research AI', isRead: false),
    ];
  }
}

final notificationProvider = AsyncNotifierProvider<NotificationNotifier, List<NotificationModel>>(() => NotificationNotifier());
`,
  'providers/settings_provider.dart': `
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings_model.dart';

class SettingsNotifier extends AsyncNotifier<SettingsModel> {
  @override
  Future<SettingsModel> build() async {
    return SettingsModel(darkMode: false, aiModel: 'gemini-1.5-pro', privacyTelemetry: true);
  }
  
  Future<void> updateSettings(SettingsModel newSettings) async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 500));
    state = AsyncValue.data(newSettings);
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, SettingsModel>(() => SettingsNotifier());
`,
  'features/notifications/screens/notifications_screen.dart': `
import 'package:flutter/material.dart';
import '../../../core/router.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) => ListTile(
          title: Text('Notification \${index + 1}'),
          onTap: () => Navigator.pushNamed(context, AppRoutes.notificationDetails),
        ),
      ),
    );
  }
}
`,
  'features/notifications/screens/notification_details_screen.dart': `
import 'package:flutter/material.dart';

class NotificationDetailsScreen extends StatelessWidget {
  const NotificationDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Details')),
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Text('Detailed message for this notification.'),
      ),
    );
  }
}
`,
  'features/settings/screens/settings_screen.dart': `
import 'package:flutter/material.dart';
import '../../../core/router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(title: const Text('User Profile'), onTap: () => Navigator.pushNamed(context, AppRoutes.userProfile)),
          ListTile(title: const Text('AI Model Config'), onTap: () => Navigator.pushNamed(context, AppRoutes.aiModelConfig)),
          ListTile(title: const Text('Privacy Settings'), onTap: () => Navigator.pushNamed(context, AppRoutes.privacySettings)),
          ListTile(title: const Text('Help Center'), onTap: () => Navigator.pushNamed(context, AppRoutes.helpCenter)),
          ListTile(title: const Text('Contact Support'), onTap: () => Navigator.pushNamed(context, AppRoutes.contactSupport)),
          ListTile(title: const Text('Feedback'), onTap: () => Navigator.pushNamed(context, AppRoutes.feedback)),
          ListTile(title: const Text('About'), onTap: () => Navigator.pushNamed(context, AppRoutes.about)),
          ListTile(title: const Text('Terms & Conditions'), onTap: () => Navigator.pushNamed(context, AppRoutes.terms)),
          ListTile(title: const Text('Logout'), onTap: () => Navigator.pushNamed(context, AppRoutes.logoutConfirm), textColor: Colors.red),
        ],
      ),
    );
  }
}
`,
  'features/settings/screens/user_profile_screen.dart': `
import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: const Center(child: Text('Edit your profile details here.')),
    );
  }
}
`,
  'features/settings/screens/ai_model_config_screen.dart': `
import 'package:flutter/material.dart';

class AiModelConfigScreen extends StatelessWidget {
  const AiModelConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Model Config')),
      body: const Center(child: Text('Select Gemini 1.5 Pro or standard models.')),
    );
  }
}
`,
  'features/settings/screens/privacy_settings_screen.dart': `
import 'package:flutter/material.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Settings')),
      body: const Center(child: Text('Manage telemetry and data tracking.')),
    );
  }
}
`,
  'features/support/screens/help_center_screen.dart': `
import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help Center')),
      body: const Center(child: Text('FAQs and Guides')),
    );
  }
}
`,
  'features/support/screens/contact_support_screen.dart': `
import 'package:flutter/material.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Support')),
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: TextField(decoration: InputDecoration(hintText: 'Describe your issue...')),
      ),
    );
  }
}
`,
  'features/support/screens/feedback_screen.dart': `
import 'package:flutter/material.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: const Center(child: Text('Rate the app! ⭐⭐⭐⭐⭐')),
    );
  }
}
`,
  'features/support/screens/about_screen.dart': `
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: const Center(child: Text('Research AI v1.0.0')),
    );
  }
}
`,
  'features/support/screens/terms_screen.dart': `
import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: const Center(child: Text('Legal texts go here.')),
    );
  }
}
`,
  'features/auth/screens/logout_confirmation_screen.dart': `
import 'package:flutter/material.dart';
import '../../../core/router.dart';

class LogoutConfirmationScreen extends StatelessWidget {
  const LogoutConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logout')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Are you sure you want to logout?'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.goodbye, (r) => false),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Confirm Logout', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}
`,
  'features/auth/screens/goodbye_screen.dart': `
import 'package:flutter/material.dart';
import '../../../core/router.dart';

class GoodbyeScreen extends StatelessWidget {
  const GoodbyeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have been logged out.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
              child: const Text('Login Again'),
            )
          ],
        ),
      ),
    );
  }
}
`
};

Object.entries(files).forEach(([file, content]) => {
  fs.writeFileSync(path.join(libDir, file), content.trim());
});

console.log('Module 4 Flutter files generated successfully.');
