// lib/routes/app_router.dart
// --- COMPLETE VERSION ---

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/core/models/user_model.dart';
import 'package:flutter_app/features/auth/presentation/providers/auth_controller.dart';
import 'package:flutter_app/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_app/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:flutter_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:flutter_app/features/customer/models/provider_model.dart';
import 'package:flutter_app/features/customer/presentation/screens/booking_screen.dart';
import 'package:flutter_app/features/customer/presentation/screens/customer_bookings_screen.dart';
import 'package:flutter_app/features/customer/presentation/screens/customer_home_screen.dart';
import 'package:flutter_app/features/customer/presentation/screens/provider_details_screen.dart';
import 'package:flutter_app/features/customer/presentation/screens/provider_list_screen.dart';
import 'package:flutter_app/features/provider/presentation/screens/provider_dashboard_screen.dart';
import 'package:flutter_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter_app/features/profile/presentation/screens/edit_profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (BuildContext context, GoRouterState state) {
      final String? role = authState.asData?.value;
      final bool loggedIn = role != null;

      final bool onLoginPage = state.matchedLocation == '/login';
      final bool onSignupPage = state.matchedLocation.startsWith('/signup');
      final bool onRoleSelectPage = state.matchedLocation == '/select-role';
      final bool onAuthFlowPage =
          onLoginPage || onSignupPage || onRoleSelectPage;

      if (loggedIn) {
        if (onAuthFlowPage) {
          return role == 'provider' ? '/provider/dashboard' : '/home';
        }
      } else {
        if (!onAuthFlowPage) {
          return '/login';
        }
      }
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
      GoRoute(
          path: '/provider/dashboard',
          builder: (c, s) => const ProviderDashboardScreen()),
      GoRoute(
        path: '/provider-details',
        builder: (context, state) {
          final Map<String, dynamic> args = state.extra as Map<String, dynamic>;
          final ProviderModel provider = args['provider'];
          final String serviceId = args['serviceId'];
          return ProviderDetailsScreen(
              provider: provider, serviceId: serviceId);
        },
      ),
      GoRoute(
        path: '/my-bookings',
        builder: (context, state) => const CustomerBookingsScreen(),
      ),

      // --- NEW ROUTES FOR PROFILE ---
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) {
              final UserModel user = state.extra as UserModel;
              return EditProfileScreen(user: user);
            },
          ),
        ],
      ),
    ],
  );
});
