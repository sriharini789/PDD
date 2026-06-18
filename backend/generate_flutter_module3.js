const fs = require('fs');
const path = require('path');

const libDir = path.join(__dirname, '..', 'lib');
const dirsToCreate = [
  'models',
  'providers',
  'features/search/screens',
  'features/library/screens',
  'features/library/widgets',
  'features/citation/screens',
  'features/notes/screens'
];

dirsToCreate.forEach(dir => {
  const fullPath = path.join(libDir, dir);
  if (!fs.existsSync(fullPath)) {
    fs.mkdirSync(fullPath, { recursive: true });
  }
});

const files = {
  'models/note_model.dart': `
class NoteModel {
  final int id;
  final int paperId;
  final String content;
  final String? highlightedText;
  final int? pageNumber;

  NoteModel({
    required this.id,
    required this.paperId,
    required this.content,
    this.highlightedText,
    this.pageNumber,
  });
}
`,
  'models/reading_list_model.dart': `
class ReadingListModel {
  final int id;
  final String name;

  ReadingListModel({required this.id, required this.name});
}
`,
  'providers/search_provider.dart': `
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/paper_model.dart';

class SearchNotifier extends AsyncNotifier<List<PaperModel>> {
  @override
  Future<List<PaperModel>> build() async {
    return [];
  }
  
  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(seconds: 1));
    state = const AsyncValue.data([]);
  }
}

final searchProvider = AsyncNotifierProvider<SearchNotifier, List<PaperModel>>(() => SearchNotifier());
`,
  'providers/library_provider.dart': `
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/paper_model.dart';
import '../models/reading_list_model.dart';

class LibraryState {
  final List<PaperModel> papers;
  final List<ReadingListModel> readingLists;
  LibraryState({this.papers = const [], this.readingLists = const []});
}

class LibraryNotifier extends AsyncNotifier<LibraryState> {
  @override
  Future<LibraryState> build() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return LibraryState();
  }
}

final libraryProvider = AsyncNotifierProvider<LibraryNotifier, LibraryState>(() => LibraryNotifier());
`,
  'providers/note_provider.dart': `
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note_model.dart';

class NoteNotifier extends AsyncNotifier<List<NoteModel>> {
  @override
  Future<List<NoteModel>> build() async {
    return [];
  }
}

final noteProvider = AsyncNotifierProvider<NoteNotifier, List<NoteModel>>(() => NoteNotifier());
`,
  'providers/citation_provider.dart': `
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CitationNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async => null;
}

final citationProvider = AsyncNotifierProvider<CitationNotifier, String?>(() => CitationNotifier());
`,
  'features/search/screens/ask_question_screen.dart': `
import 'package:flutter/material.dart';
import '../../../core/router.dart';

class AskQuestionScreen extends StatelessWidget {
  const AskQuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ask a Question')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(hintText: 'What is the impact of AI in healthcare?')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.aiAnswer),
              child: const Text('Ask AI'),
            )
          ],
        ),
      ),
    );
  }
}
`,
  'features/search/screens/ai_answer_screen.dart': `
import 'package:flutter/material.dart';

class AiAnswerScreen extends StatelessWidget {
  const AiAnswerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Answer')),
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Text('Based on 3 papers in your library... AI has a significant impact...'),
      ),
    );
  }
}
`,
  'features/search/screens/find_papers_screen.dart': `
import 'package:flutter/material.dart';
import '../../../core/router.dart';

class FindPapersScreen extends StatelessWidget {
  const FindPapersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find Relevant Papers')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(hintText: 'Search keyword...'),
              onSubmitted: (_) => Navigator.pushNamed(context, AppRoutes.searchResults),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.advancedFilters),
              child: const Text('Advanced Filters'),
            )
          ],
        ),
      ),
    );
  }
}
`,
  'features/search/screens/search_results_screen.dart': `
import 'package:flutter/material.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Results')),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) => ListTile(title: Text('Paper \${index + 1}')),
      ),
    );
  }
}
`,
  'features/search/screens/advanced_filters_screen.dart': `
import 'package:flutter/material.dart';

class AdvancedFiltersScreen extends StatelessWidget {
  const AdvancedFiltersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Filters')),
      body: const Center(child: Text('Filters go here (Year, Subject, etc)')),
    );
  }
}
`,
  'features/library/screens/my_library_screen.dart': `
import 'package:flutter/material.dart';
import '../../../core/router.dart';

class MyLibraryScreen extends StatelessWidget {
  const MyLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Library')),
      body: ListView(
        children: [
          ListTile(title: const Text('All Papers'), onTap: () => Navigator.pushNamed(context, AppRoutes.libraryPapers)),
          ListTile(title: const Text('Reading Lists'), onTap: () => Navigator.pushNamed(context, AppRoutes.readingList)),
          ListTile(title: const Text('Favorites'), onTap: () => Navigator.pushNamed(context, AppRoutes.favorites)),
        ],
      ),
    );
  }
}
`,
  'features/library/screens/library_papers_screen.dart': `
import 'package:flutter/material.dart';
import '../../../core/router.dart';

class LibraryPapersScreen extends StatelessWidget {
  const LibraryPapersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library Papers')),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => ListTile(
          title: Text('My Library Paper \${index + 1}'),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.paperActions),
          ),
        ),
      ),
    );
  }
}
`,
  'features/library/screens/paper_actions_screen.dart': `
import 'package:flutter/material.dart';
import '../../../core/router.dart';

class PaperActionsScreen extends StatelessWidget {
  const PaperActionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paper Actions')),
      body: ListView(
        children: [
          ListTile(title: const Text('Generate Citation'), onTap: () => Navigator.pushNamed(context, AppRoutes.citationGenerator)),
          ListTile(title: const Text('Notes & Highlights'), onTap: () => Navigator.pushNamed(context, AppRoutes.notes)),
          ListTile(title: const Text('Export Options'), onTap: () => Navigator.pushNamed(context, AppRoutes.exportOptions)),
        ],
      ),
    );
  }
}
`,
  'features/citation/screens/citation_generator_screen.dart': `
import 'package:flutter/material.dart';
import '../../../core/router.dart';

class CitationGeneratorScreen extends StatelessWidget {
  const CitationGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Citation Generator')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.citationGenerated),
          child: const Text('Generate APA Citation'),
        ),
      ),
    );
  }
}
`,
  'features/citation/screens/citation_generated_screen.dart': `
import 'package:flutter/material.dart';
import '../../../core/router.dart';

class CitationGeneratedScreen extends StatelessWidget {
  const CitationGeneratedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Citation Generated')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Doe, J. (2026). Impact of AI...'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.citationPreview),
              child: const Text('Preview'),
            )
          ],
        ),
      ),
    );
  }
}
`,
  'features/citation/screens/citation_preview_screen.dart': `
import 'package:flutter/material.dart';

class CitationPreviewScreen extends StatelessWidget {
  const CitationPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Citation Preview')),
      body: const Center(child: Text('Citation Preview here.')),
    );
  }
}
`,
  'features/citation/screens/export_options_screen.dart': `
import 'package:flutter/material.dart';

class ExportOptionsScreen extends StatelessWidget {
  const ExportOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export Options')),
      body: ListView(
        children: const [
          ListTile(title: Text('Export to PDF')),
          ListTile(title: Text('Export to BibTeX')),
        ],
      ),
    );
  }
}
`,
  'features/notes/screens/notes_screen.dart': `
import 'package:flutter/material.dart';
import '../../../core/router.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes and Highlights')),
      body: ListView.builder(
        itemCount: 2,
        itemBuilder: (context, index) => ListTile(title: Text('Note \${index + 1}')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addNote),
        child: const Icon(Icons.add),
      ),
    );
  }
}
`,
  'features/notes/screens/add_note_screen.dart': `
import 'package:flutter/material.dart';

class AddNoteScreen extends StatelessWidget {
  const AddNoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Note')),
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: TextField(
          maxLines: 5,
          decoration: InputDecoration(hintText: 'Enter your note...'),
        ),
      ),
    );
  }
}
`,
  'features/library/screens/reading_list_screen.dart': `
import 'package:flutter/material.dart';

class ReadingListScreen extends StatelessWidget {
  const ReadingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reading Lists')),
      body: const Center(child: Text('Your reading lists appear here.')),
    );
  }
}
`,
  'features/library/screens/favorites_screen.dart': `
import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: const Center(child: Text('Your favorite papers appear here.')),
    );
  }
}
`
};

Object.entries(files).forEach(([file, content]) => {
  fs.writeFileSync(path.join(libDir, file), content.trim());
});

console.log('Module 3 Flutter files generated successfully.');
