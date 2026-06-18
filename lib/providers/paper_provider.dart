import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/paper_model.dart';

class PaperListNotifier extends AsyncNotifier<List<PaperModel>> {
  @override
  Future<List<PaperModel>> build() async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }
}

final paperListProvider = AsyncNotifierProvider<PaperListNotifier, List<PaperModel>>(() {
  return PaperListNotifier();
});

class ActivePaperNotifier extends Notifier<PaperModel?> {
  @override
  PaperModel? build() => null;
  
  void setPaper(PaperModel? paper) {
    state = paper;
  }
}

final activePaperProvider = NotifierProvider<ActivePaperNotifier, PaperModel?>(() {
  return ActivePaperNotifier();
});