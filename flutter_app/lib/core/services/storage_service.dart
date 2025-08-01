// lib/core/services/storage_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _prefs;
  StorageService(this._prefs);

  static const _authTokenKey = 'authToken';

  Future<void> saveToken(String token) async {
    await _prefs.setString(_authTokenKey, token);
  }

  Future<String?> getToken() async {
    return _prefs.getString(_authTokenKey);
  }

  Future<void> deleteToken() async {
    await _prefs.remove(_authTokenKey);
  }
}

// Provider for SharedPreferences instance
final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// Provider for our StorageService
final storageServiceProvider = Provider<StorageService?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.when(
    data: (value) => StorageService(value),
    loading: () => null,
    error: (err, stack) => null,
  );
});
