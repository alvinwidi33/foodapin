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
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      foodId: json['foodId']?.toString() ?? json['food_id']?.toString() ?? '',
      quantity: json['quantity'] ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
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