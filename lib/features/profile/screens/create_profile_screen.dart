import 'dart:typed_data';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/responsive.dart';
import '../../../core/router.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  String _selectedLevel = 'Postgraduate';

  Uint8List? _imageBytes;

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final XFile? image =
    await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();

      setState(() {
        _imageBytes = bytes;
      });
    }
  }
  Future<void> _saveProfileImage() async {
    if (_imageBytes == null) {
      print('NO IMAGE SELECTED');
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    final imageString = base64Encode(_imageBytes!);

    await prefs.setString('profile_image', imageString);

    print('IMAGE SAVED');
    print(imageString.substring(0, 50));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ResponsiveLayout(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Create Profile'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),

              const Text(
                'Create Your Profile',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primaryLight,
                        backgroundImage: _imageBytes != null
                            ? MemoryImage(_imageBytes!)
                            : null,
                        child: _imageBytes == null
                            ? const Icon(
                          Icons.person_rounded,
                          size: 60,
                          color: AppColors.primary,
                        )
                            : null,
                      ),
                    ),

                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
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
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl * 1.5),

              const Text(
                'Research Interest',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              TextField(
                decoration: InputDecoration(
                  hintText: 'e.g. Artificial Intelligence',
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF1E1E2C)
                      : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(AppBorderRadius.md),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              const Text(
                'Academic Level',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              DropdownButtonFormField<String>(
                value: _selectedLevel,
                items: [
                  'Undergraduate',
                  'Postgraduate',
                  'PhD',
                  'Researcher',
                  'Professor'
                ]
                    .map(
                      (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ),
                )
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedLevel = v!;
                  });
                },
                dropdownColor:
                isDark ? const Color(0xFF1E1E2C) : Colors.white,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF1E1E2C)
                      : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(AppBorderRadius.md),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl * 1.5),

              ElevatedButton(
                onPressed: () async {
                  await _saveProfileImage();

                  Navigator.pushNamed(
                    context,
                    AppRoutes.selectInterests,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(AppBorderRadius.md),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save & Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}