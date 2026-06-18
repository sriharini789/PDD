import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _dataUsage = true;
  bool _chatHistory = true;
  bool _analytics = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ResponsiveLayout(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Privacy Settings'),
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
              _buildPrivacyToggle(
                context,
                'Data Usage',
                'Help improve our AI model by sharing anonymized search and analysis data.',
                _dataUsage,
                (val) => setState(() => _dataUsage = val),
              ),
              const Divider(height: 32),
              _buildPrivacyToggle(
                context,
                'Chat History',
                'Save your chat history with research papers for future reference.',
                _chatHistory,
                (val) => setState(() => _chatHistory = val),
              ),
              const Divider(height: 32),
              _buildPrivacyToggle(
                context,
                'Analytics',
                'Send anonymous usage statistics to help us improve the application experience.',
                _analytics,
                (val) => setState(() => _analytics = val),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your data is encrypted and never shared with third parties.',
                        style: TextStyle(
                          fontSize: 12, 
                          color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Privacy settings updated'),
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
                  'Save Privacy Changes', 
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

  Widget _buildPrivacyToggle(BuildContext context, String title, String subtitle, bool value, Function(bool) onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle, 
                style: TextStyle(
                  fontSize: 12, 
                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}
