// lib/features/auth/presentation/providers/auth_controller.dart
// --- COMPLETE VERSION ---

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/services/storage_service.dart';
import '../../data/auth_repository.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    final authRepository = ref.read(authRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => authRepository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
      ),
    );
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    final authRepository = ref.read(authRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final loginData =
          await authRepository.login(email: email, password: password);
      final token = loginData['accessToken'];
      final role = loginData['user']['role'];

      await ref.read(storageServiceProvider)?.saveToken(token);
      await ref.read(storageServiceProvider)?.saveRole(role);

      ref.invalidate(authStateProvider);
    });
  }

  Future<void> logoutUser() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(storageServiceProvider)?.deleteToken();
      await ref.read(storageServiceProvider)?.deleteRole();

      ref.invalidate(authStateProvider);
    });
  }
}

// --- THIS PROVIDER IS UPDATED ---
// It now returns the role as a String? (String or null)
final authStateProvider = FutureProvider<String?>((ref) async {
  final storageService = ref.watch(storageServiceProvider);
  if (storageService == null) {
    return null;
  }
  // Return the role, which will be null if the user is not logged in.
  return await storageService.getRole();
});
