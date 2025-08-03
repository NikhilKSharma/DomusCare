// lib/routes/app_router.dart
// --- COMPLETE VERSION ---

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/features/auth/presentation/providers/auth_controller.dart';
import 'package:flutter_app/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_app/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:flutter_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:flutter_app/features/customer/models/provider_model.dart';
import 'package:flutter_app/features/customer/presentation/screens/booking_screen.dart';
import 'package:flutter_app/features/customer/presentation/screens/customer_home_screen.dart';
import 'package:flutter_app/features/customer/presentation/screens/provider_list_screen.dart';
import 'package:flutter_app/features/provider/presentation/screens/provider_dashboard_screen.dart';

// Placeholder for the provider dashboard screen we will build next

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    // --- THIS REDIRECT LOGIC IS NOW ROLE-AWARE ---
    redirect: (BuildContext context, GoRouterState state) {
      // The value of authState is the role string ('customer', 'provider') or null.
      final String? role = authState.asData?.value;
      final bool loggedIn = role != null;

      final bool onLoginPage = state.matchedLocation == '/login';
      final bool onSignupPage = state.matchedLocation.startsWith('/signup');
      final bool onRoleSelectPage = state.matchedLocation == '/select-role';
      final bool onAuthFlowPage =
          onLoginPage || onSignupPage || onRoleSelectPage;

      // If the user is logged in...
      if (loggedIn) {
        // ...and trying to access an auth page, redirect them to their dashboard.
        if (onAuthFlowPage) {
          return role == 'provider' ? '/provider/dashboard' : '/home';
        }
      }
      // If the user is NOT logged in...
      else {
        // ...and trying to access any page that ISN'T an auth page, redirect to login.
        if (!onAuthFlowPage) {
          return '/login';
        }
      }

      // In all other cases, no redirect is needed.
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
      GoRoute(path: '/home', builder: (c, s) => const CustomerHomeScreen()),
      GoRoute(
        path: '/providers',
        builder: (context, state) {
          final serviceId = state.uri.queryParameters['serviceId']!;
          final serviceName = state.uri.queryParameters['serviceName']!;
          return ProviderListScreen(
            serviceId: serviceId,
            serviceName: serviceName,
          );
        },
      ),
      GoRoute(
        path: '/booking',
        builder: (context, state) {
          final Map<String, dynamic> args = state.extra as Map<String, dynamic>;
          final ProviderModel provider = args['provider'];
          final String serviceId = args['serviceId'];
          return BookingScreen(provider: provider, serviceId: serviceId);
        },
      ),
      // --- NEW ROUTE for the provider dashboard ---
      // Inside the GoRouter routes list in app_router.dart
      GoRoute(
        path: '/provider/dashboard',
        // Replace the placeholder with the real dashboard screen
        builder: (c, s) => const ProviderDashboardScreen(),
      ),
    ],
  );
});
