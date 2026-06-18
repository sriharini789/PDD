import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => authService);

final authStateProvider = StateProvider<bool>((ref) {
  return ref.watch(authServiceProvider).isAuthenticated;
});

final currentUserProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(authServiceProvider).user;
});
