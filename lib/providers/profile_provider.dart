import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_model.dart';

class ProfileNotifier extends AsyncNotifier<ProfileModel?> {
  @override
  Future<ProfileModel?> build() async {
    await Future.delayed(const Duration(seconds: 1));
    return null; // No profile initially
  }

  Future<void> createProfile(String academicLevel, List<String> interests) async {
    state = const AsyncValue.loading();
    try {
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

final profileProvider = AsyncNotifierProvider<ProfileNotifier, ProfileModel?>(() {
  return ProfileNotifier();
});