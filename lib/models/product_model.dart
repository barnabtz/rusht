class ProductModel {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final double pricePerDay;
  final List<String> images;
  final String category;
  final String location;
  final bool isAvailable;
  final DateTime createdAt;
  final Map<String, dynamic>? specifications;
  final double? rating;
  final int totalBookings;

  ProductModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.pricePerDay,
    required this.images,
    required this.category,
    required this.location,
    this.isAvailable = true,
    required this.createdAt,
    this.specifications,
    this.rating,
    this.totalBookings = 0,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      pricePerDay: (json['price_per_day'] as num).toDouble(),
      images: List<String>.from(json['images'] as List),
      category: json['category'] as String,
      location: json['location'] as String,
      isAvailable: json['is_available'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      specifications: json['specifications'] as Map<String, dynamic>?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      totalBookings: json['total_bookings'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'title': title,
      'description': description,
      'price_per_day': pricePerDay,
      'images': images,
      'category': category,
      'location': location,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'specifications': specifications,
      'rating': rating,
      'total_bookings': totalBookings,
    };
  }

  ProductModel copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    double? pricePerDay,
    List<String>? images,
    String? category,
    String? location,
    bool? isAvailable,
    DateTime? createdAt,
    Map<String, dynamic>? specifications,
    double? rating,
    int? totalBookings,
  }) {
    return ProductModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      images: images ?? this.images,
      category: category ?? this.category,
      location: location ?? this.location,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      specifications: specifications ?? this.specifications,
      rating: rating ?? this.rating,
      totalBookings: totalBookings ?? this.totalBookings,
    );
  }
}