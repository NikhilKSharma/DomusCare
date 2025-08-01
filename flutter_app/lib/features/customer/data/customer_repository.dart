// lib/features/customer/data/customer_repository.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/core/api/api_client.dart';
import '../models/service_model.dart';

class CustomerRepository {
  final http.Client _client;
  CustomerRepository(this._client);

  Future<List<ServiceModel>> fetchServices() async {
    final response = await _client.get(Uri.parse('$baseUrl/services'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      return data.map((service) => ServiceModel.fromJson(service)).toList();
    } else {
      throw Exception('Failed to load services');
    }
  }
}

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository(ref.watch(httpClientProvider));
});

// Provider to fetch the services
final servicesProvider = FutureProvider<List<ServiceModel>>((ref) {
  return ref.watch(customerRepositoryProvider).fetchServices();
});
