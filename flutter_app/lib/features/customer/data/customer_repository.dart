// lib/features/customer/data/customer_repository.dart
// --- CORRECTED VERSION ---

import 'dart:convert';
import 'package:flutter_app/core/services/storage_service.dart';
import 'package:flutter_app/features/customer/models/provider_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/core/api/api_client.dart';
import '../models/service_model.dart';
import '../models/provider_model.dart';

class CustomerRepository {
  final http.Client _client;
  final StorageService? _storageService; // <-- ADD THIS
  CustomerRepository(this._client, this._storageService);

  Future<List<ServiceModel>> fetchServices() async {
    final response = await _client.get(Uri.parse('$baseUrl/services'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      return data.map((service) => ServiceModel.fromJson(service)).toList();
    } else {
      throw Exception('Failed to load services');
    }
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storageService?.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- THIS METHOD WAS MOVED INSIDE THE CLASS ---
  Future<List<ProviderModel>> fetchProvidersByService(String serviceId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/providers?serviceId=$serviceId'),
    );

    if (response.statusCode == 200) {
      // The backend returns the root list directly, not nested under 'data'
      final data = jsonDecode(response.body) as List;
      return data.map((provider) => ProviderModel.fromJson(provider)).toList();
    } else {
      throw Exception('Failed to load providers');
    }
  }

  // ---------------------------------------------
  Future<void> createBooking({
    required String providerId,
    required String serviceId,
    required DateTime bookingTime,
    required String address,
  }) async {
    final headers = await _getAuthHeaders();
    final body = jsonEncode({
      'providerId': providerId,
      'serviceId': serviceId,
      'bookingTime': bookingTime.toIso8601String(),
      'address': address,
    });

    final response = await _client.post(
      Uri.parse('$baseUrl/bookings'),
      headers: headers,
      body: body,
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create booking');
    }
  }
} // <-- The CustomerRepository class ends here

// Provider to fetch the services
final servicesProvider = FutureProvider<List<ServiceModel>>((ref) {
  return ref.watch(customerRepositoryProvider).fetchServices();
});

// A .family provider allows us to pass in a parameter (the serviceId)
final providersByServiceProvider =
    FutureProvider.family<List<ProviderModel>, String>((ref, serviceId) {
  return ref
      .watch(customerRepositoryProvider)
      .fetchProvidersByService(serviceId);
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  // Pass the storage service to the repository
  return CustomerRepository(
    ref.watch(httpClientProvider),
    ref.watch(storageServiceProvider),
  );
});
