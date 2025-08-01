// lib/core/api/api_client.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// The base URL remains the same
final String baseUrl = Platform.isAndroid
    ? 'http://10.0.2.2:8000/api/v1'
    : 'http://localhost:8000/api/v1';

// Riverpod provider for the http.Client instance
final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});
