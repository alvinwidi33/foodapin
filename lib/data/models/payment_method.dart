class PaymentMethod {
  final String id;
  final String name;
  final String imageUrl;
  final String? virtualAccountNumber;
  final String? virtualAccountName;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.virtualAccountNumber,
    this.virtualAccountName,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      virtualAccountNumber: json['virtualAccountNumber'],
      virtualAccountName: json['virtualAccountName'],
    );
  }
}
