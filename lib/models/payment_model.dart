import 'package:flutter/foundation.dart';

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed
}

@immutable
class PaymentModel {
  final String id;
  final String bookingId;
  final double amount;
  final double platformFee;
  final PaymentStatus status;
  final String? transactionId;
  final String paymentMethod;
  final String phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentModel({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.platformFee,
    required this.status,
    this.transactionId,
    required this.paymentMethod,
    required this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      bookingId: json['booking_id'],
      amount: json['amount'].toDouble(),
      platformFee: json['platform_fee'].toDouble(),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'].toLowerCase(),
      ),
      transactionId: json['transaction_id'],
      paymentMethod: json['payment_method'],
      phoneNumber: json['phone_number'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'amount': amount,
      'platform_fee': platformFee,
      'status': status.toString().split('.').last.toUpperCase(),
      'transaction_id': transactionId,
      'payment_method': paymentMethod,
      'phone_number': phoneNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PaymentModel copyWith({
    String? id,
    String? bookingId,
    double? amount,
    double? platformFee,
    PaymentStatus? status,
    String? transactionId,
    String? paymentMethod,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      amount: amount ?? this.amount,
      platformFee: platformFee ?? this.platformFee,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
