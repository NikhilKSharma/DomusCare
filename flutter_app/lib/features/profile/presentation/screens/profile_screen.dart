// lib/features/profile/presentation/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/profile_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: profileAsync.when(
        data: (user) => RefreshIndicator(
          onRefresh: () => ref.refresh(userProfileProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              ListTile(title: const Text('Name'), subtitle: Text(user.name)),
              ListTile(title: const Text('Email'), subtitle: Text(user.email)),
              ListTile(title: const Text('Phone'), subtitle: Text(user.phone)),
              ListTile(
                  title: const Text('Address'),
                  subtitle:
                      Text(user.address.isEmpty ? 'Not set' : user.address)),
              if (user.role == 'provider') ...[
                const Divider(),
                ListTile(
                    title: const Text('Bio'),
                    subtitle: Text(user.bio.isEmpty ? 'Not set' : user.bio)),
                ListTile(
                    title: const Text('Base Price'),
                    subtitle: Text('₹${user.basePrice.toStringAsFixed(0)}')),
              ]
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text(err.toString())),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Pass the current user data to the edit screen
          final user = profileAsync.asData?.value;
          if (user != null) {
            context.go('/profile/edit', extra: user);
          }
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}
