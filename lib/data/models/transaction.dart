import 'package:foodapin/data/models/payment_method.dart';

class Transaction {
  final String id;
  final String userId;
  final String paymentMethodId;
  final String invoiceId;
  final String status;
  final int totalAmount;
  final String? proofPaymentUrl;
  final DateTime orderDate;
  final DateTime expiredDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final PaymentMethod paymentMethod;
  final List<TransactionItem> items;

  Transaction({
    required this.id,
    required this.userId,
    required this.paymentMethodId,
    required this.invoiceId,
    required this.status,
    required this.totalAmount,
    this.proofPaymentUrl,
    required this.orderDate,
    required this.expiredDate,
    required this.createdAt,
    required this.updatedAt,
    required this.paymentMethod,
    required this.items,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      userId: json['userId'],
      paymentMethodId: json['paymentMethodId'],
      invoiceId: json['invoiceId'],
      status: json['status'],
      totalAmount: json['totalAmount'],
      proofPaymentUrl: json['proofPaymentUrl'],
      orderDate: DateTime.parse(json['orderDate']),
      expiredDate: DateTime.parse(json['expiredDate']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      paymentMethod: PaymentMethod.fromJson(json['payment_method']),
      items: (json['transaction_items'] as List)
          .map((e) => TransactionItem.fromJson(e))
          .toList(),
    );
  }
}
class TransactionItem {
  final String id;
  final String transactionId;
  final String name;
  final String description;
  final String imageUrl;
  final int price;
  final int? priceDiscount;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionItem({
    required this.id,
    required this.transactionId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.priceDiscount,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'],
      transactionId: json['transactionId'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      price: json['price'],
      priceDiscount: json['priceDiscount'],
      quantity: json['quantity'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
