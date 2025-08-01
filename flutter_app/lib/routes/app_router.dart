// lib/routes/app_router.dart
// --- CORRECTED AND SECURED VERSION ---

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/features/auth/presentation/providers/auth_controller.dart';
import 'package:flutter_app/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_app/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:flutter_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:flutter_app/features/customer/presentation/screens/customer_home_screen.dart';

// --- MODIFIED HOME SCREEN WITH LOGOUT BUTTON ---
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for logout completion
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      if (next is AsyncData && previous is AsyncLoading) {
        context.go('/login');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logoutUser();
            },
          )
        ],
      ),
      body: const Center(child: Text('Welcome! You are logged in.')),
    );
  }
}
// ---------------------------------------------

// Make the router a provider so it can read other providers
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login', // Start at login
    redirect: (BuildContext context, GoRouterState state) {
      // Use authState to determine if user is logged in
      final bool loggedIn = authState.asData?.value ?? false;
      final bool onLoginPage = state.matchedLocation == '/login';
      final bool onSignupPage = state.matchedLocation.startsWith('/signup');
      final bool onRoleSelectPage = state.matchedLocation == '/select-role';

      // If not logged in and not on a public page, redirect to login
      if (!loggedIn && !onLoginPage && !onSignupPage && !onRoleSelectPage) {
        return '/login';
      }

      // If logged in and on a public page, redirect to home
      if (loggedIn && (onLoginPage || onSignupPage || onRoleSelectPage)) {
        return '/home';
      }

      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(
          path: '/select-role', builder: (c, s) => const RoleSelectionScreen()),
      GoRoute(path: '/login', builder: (c, s) => LoginScreen()),
      GoRoute(
        path: '/signup/:role',
        builder: (c, s) => SignupScreen(role: s.pathParameters['role']!),
      ),
      // Inside your GoRouter routes list
      GoRoute(
        path: '/home',
        // Replace the old HomeScreen with the new CustomerHomeScreen
        builder: (context, state) => const CustomerHomeScreen(),
      ),
    ],
  );
});
