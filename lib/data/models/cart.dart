import 'package:foodapin/data/models/foods.dart';

class Cart {
  final String id;
  final String userId;
  final String foodId;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Foods? food;

  Cart({
    required this.id,
    required this.userId,
    required this.foodId,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    this.food,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      userId: json['user_id'],
      foodId: json['food_id'],
      quantity: json['quantity'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      food: json['food'] != null
          ? Foods.fromJson(json['food'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'quantity': quantity,
    };
  }
}
