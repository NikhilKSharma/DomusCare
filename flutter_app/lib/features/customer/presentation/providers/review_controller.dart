// lib/features/customer/presentation/providers/review_controller.dart
// --- COMPLETE CORRECTED VERSION ---

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/customer/data/customer_repository.dart';

final reviewControllerProvider =
    AsyncNotifierProvider<ReviewController, void>(() {
  return ReviewController();
});

class ReviewController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> submitReview({
    required String bookingId,
    required String providerId,
    required int rating,
    required String comment,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref
        .read(customerRepositoryProvider)
        .submitReview(bookingId: bookingId, rating: rating, comment: comment));

    // Refresh the booking list and the provider's review list after submitting
    ref.invalidate(customerBookingsProvider);
    ref.invalidate(reviewsForProvider(providerId));
  }
}
