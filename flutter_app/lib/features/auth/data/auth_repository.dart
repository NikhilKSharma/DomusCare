// lib/features/auth/data/auth_repository.dart
// --- COMPLETE VERSION ---

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../core/api/api_client.dart';

class AuthRepository {
  final http.Client _client;
  AuthRepository(this._client);

  final _headers = {'Content-Type': 'application/json'};

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    final body = jsonEncode({
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
    });

    final response = await _client.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: body,
    );

    if (response.statusCode != 201) {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'An unknown error occurred';
    }
  }

  // --- THIS METHOD IS UPDATED ---
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final body = jsonEncode({
      'email': email,
      'password': password,
    });

    final response = await _client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Return the entire data map, which includes user info and the token
      return data;
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'An unknown error occurred';
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(httpClientProvider));
});
