// lib/core/models/user_model.dart

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String address;
  final String bio;
  final double basePrice;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.address,
    required this.bio,
    required this.basePrice,
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
    );
  }
}
