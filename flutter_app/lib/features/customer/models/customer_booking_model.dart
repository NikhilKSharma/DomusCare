// lib/features/customer/models/customer_booking_model.dart
// --- COMPLETE VERSION ---

class PopulatedProvider {
  final String id; // <-- ADD THIS ID
  final String name;
  PopulatedProvider(
      {required this.id, required this.name}); // <-- UPDATE CONSTRUCTOR
  factory PopulatedProvider.fromJson(Map<String, dynamic> json) {
    return PopulatedProvider(
      id: json['_id'], // <-- ADD THIS
      name: json['name'] ?? 'N/A',
    );
  }
}

class PopulatedService {
  final String name;
  PopulatedService({required this.name});
  factory PopulatedService.fromJson(Map<String, dynamic> json) {
    return PopulatedService(name: json['name'] ?? 'N/A');
  }
}

class CustomerBookingModel {
  final String id;
  final PopulatedProvider provider;
  final PopulatedService service;
  final DateTime bookingTime;
  final String status;
  final double price;

  CustomerBookingModel({
    required this.id,
    required this.provider,
    required this.service,
    required this.bookingTime,
    required this.status,
    required this.price,
  });

  factory CustomerBookingModel.fromJson(Map<String, dynamic> json) {
    return CustomerBookingModel(
      id: json['_id'],
      provider: PopulatedProvider.fromJson(json['provider']),
      service: PopulatedService.fromJson(json['service']),
      bookingTime: DateTime.parse(json['bookingTime']),
      status: json['status'],
      price: (json['price'] as num).toDouble(),
    );
  }
}
