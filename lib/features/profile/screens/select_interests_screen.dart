import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';
import '../../../core/router.dart';

class SelectInterestsScreen extends StatefulWidget {
  const SelectInterestsScreen({super.key});

  @override
  State<SelectInterestsScreen> createState() => _SelectInterestsScreenState();
}

class _SelectInterestsScreenState extends State<SelectInterestsScreen> {
  final List<String> _interests = [
    'AI',
    'Data Science',
    'NLP',
    'Computer Vision',
    'Robotics',
    'Education',
    'Medicine',
    'History',
    'Physics',
    'Biology',
    'Chemistry',
    'Other'
  ];

  final Set<String> _selected = {'AI', 'NLP'};

  Uint8List? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();

    final imageString = prefs.getString('profile_image');

    print('LOADED IMAGE = $imageString');

    if (imageString != null) {
      setState(() {
        _profileImage = base64Decode(imageString);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ResponsiveLayout(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Select Interests'),
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

              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? MemoryImage(_profileImage!)
                      : null,
                  child: _profileImage == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              const Text(
                'Select Your Interests',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              const Text(
                'Choose what you are interested in to personalize your experience.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _interests.map((interest) {
                      final isSelected =
                      _selected.contains(interest);

                      return FilterChip(
                        label: Text(interest),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() {
                            val
                                ? _selected.add(interest)
                                : _selected.remove(interest);
                          });
                        },
                        selectedColor:
                        AppColors.primary.withOpacity(0.15),
                        checkmarkColor: AppColors.primary,
                        backgroundColor: isDark
                            ? const Color(0xFF1E1E2C)
                            : Colors.grey.shade100,
                      );
                    }).toList(),
                  ),
                ),
              ),

              ElevatedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.dashboard,
                    ),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}