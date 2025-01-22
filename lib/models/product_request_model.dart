import 'package:flutter/foundation.dart';

enum RequestStatus {
  open('Open'),
  fulfilled('Fulfilled'),
  expired('Expired');

  final String displayName;
  const RequestStatus(this.displayName);
}

@immutable
class ProductRequestModel {
  final String id;
  final String requesterId;
  final String title;
  final String description;
  final String category;
  final double budgetMin;
  final double budgetMax;
  final DateTime neededBy;
  final DateTime createdAt;
  final RequestStatus status;
  final List<String> images;
  final int responseCount;

  const ProductRequestModel({
    required this.id,
    required this.requesterId,
    required this.title,
    required this.description,
    required this.category,
    required this.budgetMin,
    required this.budgetMax,
    required this.neededBy,
    required this.createdAt,
    this.status = RequestStatus.open,
    this.images = const [],
    this.responseCount = 0,
  });

  factory ProductRequestModel.fromJson(Map<String, dynamic> json) {
    return ProductRequestModel(
      id: json['id']?.toString() ?? '',
      requesterId: json['requester_id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      budgetMin: (json['budget_min'] as num?)?.toDouble() ?? 0.0,
      budgetMax: (json['budget_max'] as num?)?.toDouble() ?? 0.0,
      neededBy: DateTime.parse(json['needed_by'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      status: RequestStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String?),
        orElse: () => RequestStatus.open,
      ),
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      responseCount: (json['response_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requester_id': requesterId,
      'title': title,
      'description': description,
      'category': category,
      'budget_min': budgetMin,
      'budget_max': budgetMax,
      'needed_by': neededBy.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'status': status.name,
      'images': images,
      'response_count': responseCount,
    };
  }

  ProductRequestModel copyWith({
    String? id,
    String? requesterId,
    String? title,
    String? description,
    String? category,
    double? budgetMin,
    double? budgetMax,
    DateTime? neededBy,
    DateTime? createdAt,
    RequestStatus? status,
    List<String>? images,
    int? responseCount,
  }) {
    return ProductRequestModel(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      neededBy: neededBy ?? this.neededBy,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      images: images ?? this.images,
      responseCount: responseCount ?? this.responseCount,
    );
  }
}
