// lib/features/customer/models/review_model.dart

class Reviewer {
  final String name;
  Reviewer({required this.name});

  factory Reviewer.fromJson(Map<String, dynamic> json) {
    return Reviewer(name: json['name'] ?? 'Anonymous');
  }
}

class ReviewModel {
  final double rating;
  final String comment;
  final Reviewer customer;
  final DateTime createdAt;

  ReviewModel({
    required this.rating,
    required this.comment,
    required this.customer,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] ?? '',
      customer: Reviewer.fromJson(json['customer']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
