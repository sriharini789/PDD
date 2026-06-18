import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note_model.dart';

class NoteNotifier extends AsyncNotifier<List<NoteModel>> {
  @override
  Future<List<NoteModel>> build() async {
    return [];
  }
}

final noteProvider = AsyncNotifierProvider<NoteNotifier, List<NoteModel>>(() => NoteNotifier());