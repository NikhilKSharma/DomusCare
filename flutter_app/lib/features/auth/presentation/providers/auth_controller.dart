// lib/features/auth/presentation/providers/auth_controller.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/services/storage_service.dart';
import '../../data/auth_repository.dart';

// This provider manages the state for auth actions (like loading/error on buttons)
final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});

class AuthController extends AsyncNotifier<void> {
  // The build method is required by AsyncNotifier, but we don't need it to
  // return anything initially. Our state is updated by our methods.
  @override
  FutureOr<void> build() {
    // No-op
  }

  /// Handles user registration by calling the repository.
  Future<void> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    final authRepository = ref.read(authRepositoryProvider);
    state = const AsyncLoading(); // Set state to loading
    // AsyncValue.guard automatically handles try/catch and updates state
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

  /// Handles user login, and on success, saves the JWT to secure storage.
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    final authRepository = ref.read(authRepositoryProvider);
    state = const AsyncLoading(); // Set state to loading
    state = await AsyncValue.guard(() async {
      final token =
          await authRepository.login(email: email, password: password);
      // On success, save the token using our storage service
      await ref.read(storageServiceProvider)?.saveToken(token);
    });
  }

  /// Handles user logout by deleting the token from storage.
  Future<void> logoutUser() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // Delete the token from storage
      await ref.read(storageServiceProvider)?.deleteToken();
    });
  }
}

// --- Provider to Check Authentication State ---
// This provider is used by the router to protect routes. It checks if a
// token exists in storage to determine if the user is logged in.
final authStateProvider = FutureProvider<bool>((ref) async {
  // Watch the storage service provider. This will wait for SharedPreferences to initialize.
  final storageService = ref.watch(storageServiceProvider);

  // If the service isn't ready yet (i.e., SharedPreferences is loading),
  // we can consider the user as not authenticated.
  if (storageService == null) {
    return false;
  }

  final token = await storageService.getToken();
  // If the token is not null, the user is authenticated.
  return token != null;
});
