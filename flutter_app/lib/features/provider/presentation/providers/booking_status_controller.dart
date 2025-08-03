// lib/features/provider/presentation/providers/booking_status_controller.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/provider/data/provider_repository.dart';

final bookingStatusControllerProvider =
    AsyncNotifierProvider<BookingStatusController, void>(() {
  return BookingStatusController();
});

class BookingStatusController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> updateStatus(String bookingId, String status) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(providerRepositoryProvider)
          .updateBookingStatus(bookingId, status);
      // After updating, invalidate the provider that fetches the list
      // to force the UI to refresh with the latest data.
      ref.invalidate(providerBookingsProvider);
    });
  }
}
