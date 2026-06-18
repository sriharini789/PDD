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