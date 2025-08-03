// lib/features/customer/presentation/providers/booking_controller.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/customer/data/customer_repository.dart';

final bookingControllerProvider =
    AsyncNotifierProvider<BookingController, void>(() {
  return BookingController();
});

class BookingController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> createBooking({
    required String providerId,
    required String serviceId,
    required DateTime bookingTime,
    required String address,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref
        .read(customerRepositoryProvider)
        .createBooking(
            providerId: providerId,
            serviceId: serviceId,
            bookingTime: bookingTime,
            address: address));
  }
}
