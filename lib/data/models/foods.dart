class Foods {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<String> ingredients;
  final int price;
  final int priceDiscount;
  final int rating;
  final int totalLikes;
  final bool isLike;
  final DateTime createdAt;
  final DateTime updatedAt;

  Foods({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.ingredients,
    required this.price,
    required this.priceDiscount,
    required this.rating,
    required this.totalLikes,
    required this.isLike,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Foods.fromJson(Map<String, dynamic> json) {
    return Foods(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      price: json['price'] ?? 0,
      priceDiscount: json['price_discount'] ?? 0,
      rating: json['rating'] ?? 0,
      totalLikes: json['total_likes'] ?? 0,
      isLike: json['is_like'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'price': price,
      'price_discount': priceDiscount,
    };
  }
}
