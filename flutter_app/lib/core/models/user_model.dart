// lib/core/models/user_model.dart

// A simple representation of a service when it's part of another model
class UserService {
  final String id;
  final String name;
  UserService({required this.id, required this.name});
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String address;
  final String bio;
  final double basePrice;
  final UserService?
      service; // <-- CHANGED from a list to a single nullable object

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.address,
    required this.bio,
    required this.basePrice,
    this.service, // <-- CHANGED
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      address: json['address'] ?? '',
      bio: json['bio'] ?? '',
      basePrice: (json['basePrice'] as num? ?? 0).toDouble(),
      // Check if service data exists before trying to parse it
      service: json['service'] != null
          ? UserService(
              id: json['service']['_id'], name: json['service']['name'])
          : null, // <-- CHANGED
    );
  }
}
