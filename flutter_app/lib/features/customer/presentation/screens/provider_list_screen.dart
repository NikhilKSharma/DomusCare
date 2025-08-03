// lib/features/customer/presentation/screens/provider_list_screen.dart
// --- COMPLETE VERSION ---

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/features/customer/data/customer_repository.dart';
import '../../models/provider_model.dart';

class ProviderListScreen extends ConsumerWidget {
  final String serviceId;
  final String serviceName;
  const ProviderListScreen({
    super.key,
    required this.serviceId,
    required this.serviceName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providersAsyncValue =
        ref.watch(providersByServiceProvider(serviceId));

    return Scaffold(
      appBar: AppBar(
        title: Text(serviceName),
      ),
      body: providersAsyncValue.when(
        data: (providers) {
          if (providers.isEmpty) {
            return const Center(
              child: Text('No providers available for this service yet.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: providers.length,
            itemBuilder: (context, index) {
              final provider = providers[index];
              return ProviderCard(provider: provider, serviceId: serviceId);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: ${err.toString()}')),
      ),
    );
  }
}

class ProviderCard extends StatelessWidget {
  final ProviderModel provider;
  final String serviceId;
  const ProviderCard({
    super.key,
    required this.provider,
    required this.serviceId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          child: Text(provider.name[0]),
        ),
        title: Text(provider.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(provider.averageRating.toStringAsFixed(1)),
                const SizedBox(width: 8),
                Text('(${provider.completedJobs} jobs)'),
              ],
            ),
            const SizedBox(height: 4),
            Text('Starts at ₹${provider.basePrice.toStringAsFixed(0)}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          context.go(
            '/provider-details',
            extra: {'provider': provider, 'serviceId': serviceId},
          );
        },
      ),
    );
  }
}
