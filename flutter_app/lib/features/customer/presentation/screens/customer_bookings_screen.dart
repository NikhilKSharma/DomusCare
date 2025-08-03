// lib/features/customer/presentation/screens/customer_bookings_screen.dart
// --- COMPLETE VERSION ---

import 'package:flutter_app/features/customer/data/customer_repository.dart';
import 'package:flutter_app/features/customer/models/customer_booking_model.dart';
import 'package:flutter_app/features/customer/presentation/providers/review_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomerBookingsScreen extends ConsumerWidget {
  const CustomerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(customerBookingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return const Center(child: Text('You have no bookings yet.'));
          }
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return CustomerBookingCard(booking: bookings[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text(err.toString())),
      ),
    );
  }
}

class CustomerBookingCard extends StatelessWidget {
  final CustomerBookingModel booking;
  const CustomerBookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    // We'll add a flag later to check if a booking has already been reviewed
    final bool canReview = booking.status == 'Completed';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(booking.service.name,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('with ${booking.provider.name}',
                style: Theme.of(context).textTheme.titleMedium),
            const Divider(height: 16),
            Text(
                'Date: ${DateFormat.yMMMd().add_jm().format(booking.bookingTime.toLocal())}'),
            Text('Status: ${booking.status}'),
            Text('Price: ₹${booking.price.toStringAsFixed(0)}'),
            if (canReview)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  child: const Text('RATE PROVIDER'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => SubmitReviewDialog(
                        bookingId: booking.id,
                        providerId: booking.provider.id, // Pass providerId
                      ),
                    );
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
}

class SubmitReviewDialog extends ConsumerStatefulWidget {
  final String bookingId;
  final String providerId;
  const SubmitReviewDialog(
      {super.key, required this.bookingId, required this.providerId});

  @override
  ConsumerState<SubmitReviewDialog> createState() => _SubmitReviewDialogState();
}

class _SubmitReviewDialogState extends ConsumerState<SubmitReviewDialog> {
  int _rating = 0;
  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ref.listen(reviewControllerProvider, (previous, next) {
      if (!next.isLoading && !next.hasError) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review submitted successfully!')));
      } else if (next.hasError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
    });

    final reviewState = ref.watch(reviewControllerProvider);

    return AlertDialog(
      title: const Text('Leave a Review'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => setState(() => _rating = index + 1),
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                );
              }),
            ),
            TextField(
              controller: _commentController,
              decoration:
                  const InputDecoration(labelText: 'Comment (optional)'),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL')),
        ElevatedButton(
          onPressed: (_rating == 0 || reviewState.isLoading)
              ? null
              : () {
                  ref.read(reviewControllerProvider.notifier).submitReview(
                        bookingId: widget.bookingId,
                        providerId: widget.providerId,
                        rating: _rating,
                        comment: _commentController.text,
                      );
                },
          child: reviewState.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                  ))
              : const Text('SUBMIT'),
        ),
      ],
    );
  }
}
