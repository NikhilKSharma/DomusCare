// lib/features/provider/models/provider_booking_model.dart

// A simple model for the nested customer data
class PopulatedCustomer {
  final String id;
  final String name;
  final String? phone;

  PopulatedCustomer({required this.id, required this.name, this.phone});

  factory PopulatedCustomer.fromJson(Map<String, dynamic> json) {
    return PopulatedCustomer(
      id: json['_id'],
      name: json['name'],
      phone: json['phone'],
    );
  }
}

// A simple model for the nested service data
class PopulatedService {
  final String id;
  final String name;

  PopulatedService({required this.id, required this.name});

  factory PopulatedService.fromJson(Map<String, dynamic> json) {
    return PopulatedService(
      id: json['_id'],
      name: json['name'],
    );
  }
}

class ProviderBookingModel {
  final String id;
  final PopulatedCustomer customer;
  final PopulatedService service;
  final DateTime bookingTime;
  final String status;
  final String address;
  final double price;

  ProviderBookingModel({
    required this.id,
    required this.customer,
    required this.service,
    required this.bookingTime,
    required this.status,
    required this.address,
    required this.price,
  });

  factory ProviderBookingModel.fromJson(Map<String, dynamic> json) {
    return ProviderBookingModel(
      id: json['_id'],
      customer: PopulatedCustomer.fromJson(json['customer']),
      service: PopulatedService.fromJson(json['service']),
      bookingTime: DateTime.parse(json['bookingTime']),
      status: json['status'],
      address: json['address'],
      price: (json['price'] as num).toDouble(),
    );
  }
}
