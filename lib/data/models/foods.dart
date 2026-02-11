class Foods {
  final String? id;
  final String name;
  final String description;
  final String imageUrl;
  final List<String> ingredients;
  final int? price;
  final int? priceDiscount;
  final int? rating;
  final int? totalLikes;
  final bool? isLike;
  final DateTime createdAt;
  final DateTime updatedAt;

  Foods({
    this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.ingredients,
    this.price,
    this.priceDiscount,
    this.rating,
    this.totalLikes,
    this.isLike,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Foods.fromJson(Map<String, dynamic> json) {
    return Foods(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),

      price: json['price'],
      priceDiscount: json['priceDiscount'],
      rating: json['rating'],
      totalLikes: json['totalLikes'],       
      isLike: json['isLike'],            

      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),               

      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
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
