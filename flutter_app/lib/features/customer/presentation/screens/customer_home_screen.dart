// lib/features/customer/presentation/screens/customer_home_screen.dart
// --- UPDATED NAVIGATION LOGIC ---

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Make sure GoRouter is imported
import 'package:flutter_app/features/customer/data/customer_repository.dart';
import 'package:flutter_app/features/auth/presentation/providers/auth_controller.dart';
import '../../models/service_model.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsyncValue = ref.watch(servicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DomusCare'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Open a drawer or perform some action
          },
        ),
        actions: [/* ... */],
      ),
      body: servicesAsyncValue.when(
        data: (services) => GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return ServiceCard(service: service);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: ${err.toString()}')),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  const ServiceCard({super.key, required this.service});

  static const Map<String, IconData> iconMap = {
    'plumbing': Icons.plumbing,
    'cleaning': Icons.cleaning_services,
    'electrical': Icons.electrical_services,
    'carpenter': Icons.handyman,
    'painter': Icons.format_paint,
    'pest_control': Icons.pest_control,
    'ac_repair': Icons.ac_unit,
    'gardener': Icons.local_florist,
    'security_installer': Icons.security,
  };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // --- THIS IS THE UPDATED NAVIGATION CALL ---
        final serviceNameEncoded = Uri.encodeComponent(service.name);
        context.go(
            '/providers?serviceId=${service.id}&serviceName=$serviceNameEncoded');
        // --------------------------------------------
      },
      borderRadius: BorderRadius.circular(8.0),
      child: Card(
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconMap[service.icon.toLowerCase()] ??
                  Icons.miscellaneous_services,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              service.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
