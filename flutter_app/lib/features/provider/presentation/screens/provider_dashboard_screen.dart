// lib/features/provider/presentation/screens/provider_dashboard_screen.dart
// --- UPDATED VERSION ---

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/auth/presentation/providers/auth_controller.dart';
import 'package:flutter_app/features/provider/data/provider_repository.dart';
import 'package:flutter_app/features/provider/models/provider_booking_model.dart';
import 'package:flutter_app/features/provider/presentation/providers/booking_status_controller.dart';
import 'package:intl/intl.dart';

class ProviderDashboardScreen extends ConsumerWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(providerBookingsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).logoutUser(),
            )
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending Requests'),
              Tab(text: 'Upcoming Jobs'),
            ],
          ),
        ),
        body: bookingsAsync.when(
          data: (bookings) {
            final pending =
                bookings.where((b) => b.status == 'Pending').toList();
            final upcoming =
                bookings.where((b) => b.status == 'Accepted').toList();

            return TabBarView(
              children: [
                BookingListView(bookings: pending, isPending: true),
                BookingListView(bookings: upcoming, isPending: false),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              Center(child: Text('Error: ${err.toString()}')),
        ),
      ),
    );
  }
}

class BookingListView extends StatelessWidget {
  final List<ProviderBookingModel> bookings;
  final bool isPending;
  const BookingListView(
      {super.key, required this.bookings, required this.isPending});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
          child:
              Text('No ${isPending ? 'pending requests' : 'upcoming jobs'}.'));
    }
    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return BookingRequestCard(booking: bookings[index]);
      },
    );
  }
}

class BookingRequestCard extends ConsumerWidget {
  final ProviderBookingModel booking;
  const BookingRequestCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(booking.customer.name,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(booking.service.name,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(DateFormat.yMMMd()
                .add_jm()
                .format(booking.bookingTime.toLocal())),
            Text(booking.address),
            const SizedBox(height: 8),

            // --- THIS LOGIC IS UPDATED ---
            if (booking.status == 'Pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      ref
                          .read(bookingStatusControllerProvider.notifier)
                          .updateStatus(booking.id, 'Cancelled');
                    },
                    child: const Text('REJECT'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(bookingStatusControllerProvider.notifier)
                          .updateStatus(booking.id, 'Accepted');
                    },
                    child: const Text('ACCEPT'),
                  ),
                ],
              )
            else if (booking.status == 'Accepted')
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    ref
                        .read(bookingStatusControllerProvider.notifier)
                        .updateStatus(booking.id, 'Completed');
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('MARK AS COMPLETE'),
                ),
              ),
            // -----------------------------
          ],
        ),
      ),
    );
  }
}
