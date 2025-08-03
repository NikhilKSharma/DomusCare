// lib/features/profile/data/profile_repository.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter_app/core/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/core/api/api_client.dart';
import 'package:flutter_app/core/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileRepository {
  final http.Client _client;
  final StorageService? _storageService;
  ProfileRepository(this._client, this._storageService);

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storageService?.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<UserModel> getMyProfile() async {
    final headers = await _getAuthHeaders();
    final response =
        await _client.get(Uri.parse('$baseUrl/users/me'), headers: headers);

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<UserModel> updateMyProfile(Map<String, dynamic> data) async {
    final headers = await _getAuthHeaders();
    final body = jsonEncode(data);
    final response = await _client.put(Uri.parse('$baseUrl/users/me'),
        headers: headers, body: body);

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to update profile');
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(
      ref.watch(httpClientProvider), ref.watch(storageServiceProvider));
});

final userProfileProvider = FutureProvider<UserModel>((ref) {
  // Automatically refetch when the controller invalidates it
  return ref.watch(profileRepositoryProvider).getMyProfile();
});

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, void>(() {
  return ProfileController();
});

class ProfileController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> updateProfile(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(profileRepositoryProvider).updateMyProfile(data);
      // Invalidate the userProfileProvider to refetch the updated data
      ref.invalidate(userProfileProvider);
    });
  }
}
