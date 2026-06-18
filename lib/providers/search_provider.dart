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