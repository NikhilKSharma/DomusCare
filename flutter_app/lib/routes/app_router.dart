// lib/routes/app_router.dart
// --- CORRECTED VERSION ---

import 'package:flutter_app/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_app/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:flutter_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// Placeholder for home screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Welcome!')));
}

final router = GoRouter(
  initialLocation: '/select-role',
  routes: [
    GoRoute(
      path: '/select-role',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/login',
      // The 'const' keyword has been removed from here. This is the fix.
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/signup/:role', // Role is passed as a path parameter
      builder: (context, state) {
        final role = state.pathParameters['role']!;
        // This was already correct (no const) because SignupScreen has non-const fields.
        return SignupScreen(role: role);
      },
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
