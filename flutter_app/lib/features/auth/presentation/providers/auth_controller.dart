// lib/features/auth/presentation/providers/auth_controller.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';

// This provider will be watched by the UI to show loading states, errors, etc.
final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});

class AuthController extends AsyncNotifier<void> {
  // The build method is required by AsyncNotifier, but we don't need it to
  // return anything initially. Our state will be updated by our methods.
  @override
  FutureOr<void> build() {
    // No-op
  }

  Future<void> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    final authRepository = ref.read(authRepositoryProvider);
    state = const AsyncLoading(); // Set state to loading
    state = await AsyncValue.guard(
      // Handles try/catch and sets state to AsyncData/AsyncError
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
    state = const AsyncLoading(); // Set state to loading
    state = await AsyncValue.guard(() async {
      final token =
          await authRepository.login(email: email, password: password);
      // In the next step, we will save this token to secure storage
      print('✅ Logged In! Token: $token');
    });
  }
}
