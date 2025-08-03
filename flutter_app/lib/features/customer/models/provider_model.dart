// lib/features/customer/models/provider_model.dart
class ProviderModel {
  final String id;
  final String name;
  final String profilePicture;
  final String bio;
  final double basePrice;
  final double averageRating;
  final int completedJobs;

  ProviderModel({
    required this.id,
    required this.name,
    required this.profilePicture,
    required this.bio,
    required this.basePrice,
    required this.averageRating,
    required this.completedJobs,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['_id'],
      name: json['name'],
      profilePicture: json['profilePicture'] ?? '',
      bio: json['bio'] ?? 'No bio available.',
      // Ensure number types are handled correctly
      basePrice: (json['basePrice'] as num).toDouble(),
      averageRating: (json['averageRating'] as num).toDouble(),
      completedJobs: json['completedJobs'] ?? 0,
    );
  }
}
