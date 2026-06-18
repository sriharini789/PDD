const fs = require('fs');
const path = require('path');

const libDir = path.join(__dirname, '..', 'lib');
const dirsToCreate = [
  'models',
  'providers',
  'features/profile/screens',
  'features/dashboard/screens',
  'features/dashboard/widgets',
  'features/paper/screens',
  'features/paper/widgets'
];

dirsToCreate.forEach(dir => {
  const fullPath = path.join(libDir, dir);
  if (!fs.existsSync(fullPath)) {
    fs.mkdirSync(fullPath, { recursive: true });
  }
});

const files = {
  'models/profile_model.dart': `
class ProfileModel {
  final int userId;
  final String academicLevel;
  final List<String> interests;
  final String? avatarUrl;

  ProfileModel({
    required this.userId,
    required this.academicLevel,
    required this.interests,
    this.avatarUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['user_id'] ?? 0,
      academicLevel: json['academic_level'] ?? '',
      interests: List<String>.from(json['interests'] ?? []),
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'academic_level': academicLevel,
      'interests': interests,
      'avatar_url': avatarUrl,
    };
  }
}
`,
  'models/paper_model.dart': `
class PaperModel {
  final int id;
  final int userId;
  final String title;
  final String authors;
  final String status;
  final String processingStage;
  final String summary;
  final List<String> topics;
  final String content;

  PaperModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.authors,
    required this.status,
    required this.processingStage,
    required this.summary,
    required this.topics,
    required this.content,
  });

  factory PaperModel.fromJson(Map<String, dynamic> json) {
    return PaperModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      title: json['title'] ?? '',
      authors: json['authors'] ?? '',
      status: json['status'] ?? '',
      processingStage: json['processing_stage'] ?? '',
      summary: json['summary'] ?? '',
      topics: List<String>.from(json['topics'] ?? []),
      content: json['content'] ?? '',
    );
  }
}
`,
  'providers/profile_provider.dart': `
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final profileProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<ProfileModel?>>((ref) {
  return ProfileNotifier();
});

class ProfileNotifier extends StateNotifier<AsyncValue<ProfileModel?>> {
  ProfileNotifier() : super(const AsyncValue.loading()) {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      // Mocking API fetch
      await Future.delayed(const Duration(seconds: 1));
      state = AsyncValue.data(null); // No profile initially
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createProfile(String academicLevel, List<String> interests) async {
    state = const AsyncValue.loading();
    try {
      // Mocking API call
      await Future.delayed(const Duration(seconds: 1));
      final newProfile = ProfileModel(
        userId: 1, 
        academicLevel: academicLevel, 
        interests: interests,
      );
      state = AsyncValue.data(newProfile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
`,
  'providers/paper_provider.dart': `
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/paper_model.dart';

final paperListProvider = StateNotifierProvider<PaperListNotifier, AsyncValue<List<PaperModel>>>((ref) {
  return PaperListNotifier();
});

class PaperListNotifier extends StateNotifier<AsyncValue<List<PaperModel>>> {
  PaperListNotifier() : super(const AsyncValue.loading()) {
    fetchPapers();
  }

  Future<void> fetchPapers() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      state = const AsyncValue.data([]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final activePaperProvider = StateProvider<PaperModel?>((ref) => null);
`,
  'features/profile/screens/create_profile_screen.dart': `
import 'package:flutter/material.dart';
import '../../../core/router.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  String _selectedLevel = 'Undergraduate';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Create Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Academic Level', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedLevel,
              items: ['Undergraduate', 'Postgraduate', 'PhD', 'Researcher']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedLevel = v!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.selectInterests),
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
`,
  'features/profile/screens/select_interests_screen.dart': `
import 'package:flutter/material.dart';
import '../../../core/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/profile_provider.dart';

class SelectInterestsScreen extends ConsumerStatefulWidget {
  const SelectInterestsScreen({super.key});

  @override
  ConsumerState<SelectInterestsScreen> createState() => _SelectInterestsScreenState();
}

class _SelectInterestsScreenState extends ConsumerState<SelectInterestsScreen> {
  final List<String> _availableInterests = ['AI', 'NLP', 'Computer Vision', 'Robotics', 'Data Science'];
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Interests')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8.0,
              children: _availableInterests.map((interest) {
                final isSelected = _selected.contains(interest);
                return FilterChip(
                  label: Text(interest),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      val ? _selected.add(interest) : _selected.remove(interest);
                    });
                  },
                );
              }).toList(),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                ref.read(profileProvider.notifier).createProfile('PhD', _selected.toList());
                Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
              },
              child: const Text('Complete Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
`,
  'features/dashboard/screens/dashboard_screen.dart': `
import 'package:flutter/material.dart';
import '../../../core/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Good Morning!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.uploadPaper),
                    child: const Text('Upload Paper'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
`,
  'features/paper/screens/upload_paper_screen.dart': `
import 'package:flutter/material.dart';
import '../../../core/router.dart';

class UploadPaperScreen extends StatelessWidget {
  const UploadPaperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Paper')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.uploading),
          child: const Text('Simulate Upload'),
        ),
      ),
    );
  }
}
`,
  'features/paper/screens/uploading_screen.dart': `
import 'package:flutter/material.dart';
import '../../../core/router.dart';

class UploadingScreen extends StatefulWidget {
  const UploadingScreen({super.key});

  @override
  State<UploadingScreen> createState() => _UploadingScreenState();
}

class _UploadingScreenState extends State<UploadingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.processing);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Uploading...'),
          ],
        ),
      ),
    );
  }
}
`,
  'features/paper/screens/processing_screen.dart': `
import 'package:flutter/material.dart';
import '../../../core/router.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.processingComplete);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing with AI...'),
          ],
        ),
      ),
    );
  }
}
`,
  'features/paper/screens/processing_complete_screen.dart': `
import 'package:flutter/material.dart';
import '../../../core/router.dart';

class ProcessingCompleteScreen extends StatelessWidget {
  const ProcessingCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text('Processing Complete'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.paperDetail),
              child: const Text('View Paper Details'),
            ),
          ],
        ),
      ),
    );
  }
}
`,
  'features/paper/screens/paper_detail_screen.dart': `
import 'package:flutter/material.dart';
import '../../../core/router.dart';

class PaperDetailScreen extends StatelessWidget {
  const PaperDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paper Details')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Sample Paper Title', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.paperFull),
              child: const Text('Read Full Paper'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.chatPaper),
              child: const Text('Chat with Paper'),
            ),
          ],
        ),
      ),
    );
  }
}
`,
  'features/paper/screens/paper_full_screen.dart': `
import 'package:flutter/material.dart';

class PaperFullScreen extends StatelessWidget {
  const PaperFullScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Full Paper')),
      body: const Center(child: Text('Full paper content goes here.')),
    );
  }
}
`,
  'features/paper/screens/chat_paper_screen.dart': `
import 'package:flutter/material.dart';

class ChatPaperScreen extends StatelessWidget {
  const ChatPaperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat with Paper')),
      body: Column(
        children: [
          Expanded(child: Center(child: Text('Chat messages go here.'))),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Ask a question...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
`
};

Object.entries(files).forEach(([file, content]) => {
  fs.writeFileSync(path.join(libDir, file), content.trim());
});

console.log('Dart files generated successfully.');
