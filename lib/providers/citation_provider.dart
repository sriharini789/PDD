import 'package:flutter_riverpod/flutter_riverpod.dart';

class CitationNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async => null;
}

final citationProvider = AsyncNotifierProvider<CitationNotifier, String?>(() => CitationNotifier());