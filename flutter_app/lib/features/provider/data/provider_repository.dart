// lib/features/provider/data/provider_repository.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/core/api/api_client.dart';
import 'package:flutter_app/core/services/storage_service.dart';
import 'package:flutter_app/features/provider/models/provider_booking_model.dart';

class ProviderRepository {
  final http.Client _client;
  final StorageService? _storageService;
  ProviderRepository(this._client, this._storageService);

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storageService?.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<ProviderBookingModel>> getMyBookings() async {
    final headers = await _getAuthHeaders();
    final response = await _client.get(
      Uri.parse('$baseUrl/bookings'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      return data.map((b) => ProviderBookingModel.fromJson(b)).toList();
    } else {
      throw Exception('Failed to load bookings');
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    final headers = await _getAuthHeaders();
    final body = jsonEncode({'status': status});
    final response = await _client.patch(
      Uri.parse('$baseUrl/bookings/$bookingId/status'),
      headers: headers,
      body: body,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update booking status');
    }
  }
}

final providerRepositoryProvider = Provider<ProviderRepository>((ref) {
  return ProviderRepository(
    ref.watch(httpClientProvider),
    ref.watch(storageServiceProvider),
  );
});

final providerBookingsProvider =
    FutureProvider<List<ProviderBookingModel>>((ref) {
  return ref.watch(providerRepositoryProvider).getMyBookings();
});
