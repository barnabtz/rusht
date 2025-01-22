import 'package:flutter/foundation.dart';

enum BookingStatus {
  pending('Pending'),
  confirmed('Confirmed'),
  active('Active'),
  completed('Completed'),
  cancelled('Cancelled'),
  declined('Declined');

  final String displayName;
  const BookingStatus(this.displayName);
}

@immutable
class BookingModel {
  final String id;
  final String productId;
  final String renterId;
  final String ownerId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final BookingStatus status;
  final String? cancellationReason;
  final DateTime createdAt;
  final double? rating;
  final String? review;

  const BookingModel({
    required this.id,
    required this.productId,
    required this.renterId,
    required this.ownerId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    this.status = BookingStatus.pending,
    this.cancellationReason,
    required this.createdAt,
    this.rating,
    this.review,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    final renterProfile = json['renter_profile'] as Map<String, dynamic>?;
    final ownerProfile = json['owner_profile'] as Map<String, dynamic>?;
    
    return BookingModel(
      id: json['id']?.toString() ?? '',
      productId: (product?['id'] ?? json['product_id'])?.toString() ?? '',
      renterId: (renterProfile?['id'] ?? json['renter_id'])?.toString() ?? '',
      ownerId: (ownerProfile?['id'] ?? json['owner_id'])?.toString() ?? '',
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      totalPrice: (json['total_price'] as num).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String?),
        orElse: () => BookingStatus.pending,
      ),
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      review: json['review'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'renter_id': renterId,
      'owner_id': ownerId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'total_price': totalPrice,
      'status': status.name,
      'cancellation_reason': cancellationReason,
      'created_at': createdAt.toIso8601String(),
      'rating': rating,
      'review': review,
    };
  }

  BookingModel copyWith({
    String? id,
    String? productId,
    String? renterId,
    String? ownerId,
    DateTime? startDate,
    DateTime? endDate,
    double? totalPrice,
    BookingStatus? status,
    String? cancellationReason,
    DateTime? createdAt,
    double? rating,
    String? review,
  }) {
    return BookingModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      renterId: renterId ?? this.renterId,
      ownerId: ownerId ?? this.ownerId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      rating: rating ?? this.rating,
      review: review ?? this.review,
    );
  }

  int get durationInDays =>
      endDate.difference(startDate).inDays + 1;

  bool get isActive =>
      status == BookingStatus.active;

  bool get isPending =>
      status == BookingStatus.pending;

  bool get isCompleted =>
      status == BookingStatus.completed;

  bool get isCancelled =>
      status == BookingStatus.cancelled;
}