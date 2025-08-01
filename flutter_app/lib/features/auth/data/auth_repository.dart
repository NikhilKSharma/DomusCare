// lib/features/auth/data/auth_repository.dart
import 'dart:convert'; // Required for jsonEncode and jsonDecode
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../core/api/api_client.dart';

class AuthRepository {
  final http.Client _client;
  AuthRepository(this._client);

  // We need to manually set headers for POST requests
  final _headers = {'Content-Type': 'application/json'};

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    final body = jsonEncode({
      // Manually encode the body to JSON
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
    });

    final response = await _client.post(
      Uri.parse('$baseUrl/auth/register'), // Manually construct the full URL
      headers: _headers,
      body: body,
    );

    if (response.statusCode != 201) {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'An unknown error occurred';
    }
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final body = jsonEncode({
      // Manually encode body
      'email': email,
      'password': password,
    });

    final response = await _client.post(
      Uri.parse('$baseUrl/auth/login'), // Manually construct URL
      headers: _headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); // Manually decode response
      return data['accessToken'];
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'An unknown error occurred';
    }
  }
}

// Update the provider to use the new httpClientProvider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(httpClientProvider));
});
