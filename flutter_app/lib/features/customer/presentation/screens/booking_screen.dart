// lib/features/customer/presentation/screens/booking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/provider_model.dart';
import '../providers/booking_controller.dart';
import 'package:go_router/go_router.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final ProviderModel provider;
  final String serviceId;

  const BookingScreen(
      {super.key, required this.provider, required this.serviceId});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime? _selectedDateTime;

  Future<void> _selectDateTime(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(bookingControllerProvider, (previous, next) {
      next.when(
        error: (error, stackTrace) => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString()))),
        loading: () {},
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Booking created successfully!')));
          context.pop(); // Go back to the provider list
        },
      );
    });

    final bookingState = ref.watch(bookingControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Provider details
            ListTile(
              leading: CircleAvatar(child: Text(widget.provider.name[0])),
              title: Text(widget.provider.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Row(children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                Text(widget.provider.averageRating.toStringAsFixed(1))
              ]),
            ),
            const Divider(height: 32),

            // Date & Time Picker
            ElevatedButton.icon(
              onPressed: () => _selectDateTime(context),
              icon: const Icon(Icons.calendar_today),
              label: const Text('Select Date & Time'),
            ),
            const SizedBox(height: 16),
            if (_selectedDateTime != null)
              Text(
                'Selected: ${DateFormat.yMMMd().add_jm().format(_selectedDateTime!)}',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

            const Spacer(),

            // Price and Confirm button
            Text('Base Cost: ₹${widget.provider.basePrice.toStringAsFixed(0)}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              onPressed: (_selectedDateTime == null || bookingState.isLoading)
                  ? null
                  : () {
                      ref
                          .read(bookingControllerProvider.notifier)
                          .createBooking(
                            providerId: widget.provider.id,
                            serviceId: widget.serviceId,
                            bookingTime: _selectedDateTime!,
                            address:
                                '123 Main St, Anytown', // TODO: Get address from user profile
                          );
                    },
              child: bookingState.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Book Now', style: TextStyle(fontSize: 18)),
            )
          ],
        ),
      ),
    );
  }
}
