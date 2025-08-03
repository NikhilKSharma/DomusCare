// lib/features/customer/presentation/screens/provider_details_screen.dart
// --- COMPLETE CORRECTED VERSION ---

import 'package:flutter_app/features/customer/data/customer_repository.dart';
import 'package:flutter_app/features/customer/models/provider_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/review_model.dart';

class ProviderDetailsScreen extends ConsumerWidget {
  final ProviderModel provider;
  final String serviceId;
  const ProviderDetailsScreen(
      {super.key, required this.provider, required this.serviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(reviewsForProvider(provider.id));

    return Scaffold(
      appBar: AppBar(title: Text(provider.name)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80.0), // Space for the FAB
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Provider Info Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                        radius: 40,
                        child: Text(provider.name[0],
                            style: const TextStyle(fontSize: 32))),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(provider.name,
                              style: Theme.of(context).textTheme.headlineSmall),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 20),
                              Text(
                                  ' ${provider.averageRating.toStringAsFixed(1)} (${provider.completedJobs} jobs)'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                    provider.bio.isEmpty ? "No bio available." : provider.bio),
              ),
              const Divider(height: 32),

              // Reviews Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text("Reviews",
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              reviewsAsync.when(
                data: (reviews) {
                  if (reviews.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: Text("No reviews yet.")),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return ListTile(
                        title: Row(
                          children: List.generate(5, (starIndex) {
                            return Icon(
                              starIndex < review.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            );
                          }),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (review.comment.isNotEmpty) Text(review.comment),
                            const SizedBox(height: 4),
                            Text(
                              "- ${review.customer.name}, ${DateFormat.yMMMd().format(review.createdAt.toLocal())}",
                              style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    const Center(child: Text("Could not load reviews.")),
              )
            ],
          ),
        ),
      ),
      // Floating Action Button to Book
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/booking',
              extra: {'provider': provider, 'serviceId': serviceId});
        },
        label: Text("Book Now (₹${provider.basePrice.toStringAsFixed(0)})"),
        icon: const Icon(Icons.calendar_today),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
