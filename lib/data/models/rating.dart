class RatingUser {
  final String id;
  final String name;
  final String email;
  final String profilePictureUrl;
  final String phoneNumber;

  RatingUser({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePictureUrl,
    required this.phoneNumber,
  });

  factory RatingUser.fromJson(Map<String, dynamic> json) {
    return RatingUser(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profilePictureUrl: json['profilePictureUrl'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }
}

class FoodRating {
  final String id;
  final int rating;
  final String review;
  final RatingUser user;

  FoodRating({
    required this.id,
    required this.rating,
    required this.review,
    required this.user,
  });

  factory FoodRating.fromJson(Map<String, dynamic> json) {
    return FoodRating(
      id: json['id'],
      rating: json['rating'],
      review: json['review'] ?? '',
      user: RatingUser.fromJson(json['user']),
    );
  }
}
