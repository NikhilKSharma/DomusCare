// lib/features/customer/models/service_model.dart
class ServiceModel {
  final String id;
  final String name;
  final String icon;

  ServiceModel({required this.id, required this.name, required this.icon});

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id'],
      name: json['name'],
      icon: json['icon'],
    );
  }
}
