// lib/core/api/api_client.dart
// --- CORRECTED VERSION ---

import 'package:flutter/foundation.dart' show kIsWeb; // Use this for web checks
import 'dart:io' show Platform; // This is safe now because of the kIsWeb guard
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

String getBaseUrl() {
  // Check if the app is running on the web
  if (kIsWeb) {
    return 'http://localhost:8000/api/v1';
  }

  // If not on web, it's safe to use dart:io's Platform class
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8000/api/v1';
  } else {
    // For iOS, desktop, etc.
    return 'http://localhost:8000/api/v1';
  }
}

// Use the function to get the correct baseUrl
final String baseUrl = getBaseUrl();

// Riverpod provider for the http.Client instance
final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});
