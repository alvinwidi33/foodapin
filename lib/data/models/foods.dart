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
  Foods copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    List<String>? ingredients,
    int? price,
    int? priceDiscount,
    int? rating,
    int? totalLikes,
    bool? isLike,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Foods(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      price: price ?? this.price,
      priceDiscount: priceDiscount ?? this.priceDiscount,
      rating: rating ?? this.rating,
      totalLikes: totalLikes ?? this.totalLikes,
      isLike: isLike ?? this.isLike,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

}
