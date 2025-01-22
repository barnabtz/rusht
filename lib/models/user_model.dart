import 'package:rusht/models/verification_status.dart';

class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final DateTime createdAt;
  final bool isOwner;
  final String? address;
  final double? rating;
  final VerificationStatus verificationStatus;
  final String? selfieWithIdUrl;
  final DateTime? verifiedAt;
  final String? verificationRejectionReason;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    required this.createdAt,
    this.isOwner = false,
    this.address,
    this.rating,
    this.verificationStatus = VerificationStatus.unverified,
    this.selfieWithIdUrl,
    this.verifiedAt,
    this.verificationRejectionReason,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isOwner: json['is_owner'] as bool? ?? false,
      address: json['address'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      verificationStatus: json['verification_status'] != null
          ? _parseVerificationStatus(json['verification_status'])
          : VerificationStatus.unverified,
      selfieWithIdUrl: json['selfie_with_id_url'] as String?,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
      verificationRejectionReason: json['verification_rejection_reason'] as String?,
    );
  }

  static VerificationStatus _parseVerificationStatus(dynamic status) {
    if (status is int) {
      return VerificationStatus.values[status];
    } else if (status is String) {
      // Handle string representations of verification status
      switch (status.toLowerCase()) {
        case 'unverified':
          return VerificationStatus.unverified;
        case 'pending':
          return VerificationStatus.pending;
        case 'approved':
          return VerificationStatus.approved;
        case 'rejected':
          return VerificationStatus.rejected;
        default:
          return VerificationStatus.unverified;
      }
    }
    return VerificationStatus.unverified;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'is_owner': isOwner,
      'address': address,
      'rating': rating,
      'verification_status': verificationStatus.index,
      'selfie_with_id_url': selfieWithIdUrl,
      'verified_at': verifiedAt?.toIso8601String(),
      'verification_rejection_reason': verificationRejectionReason,
    };
  }

  bool get isVerified => verificationStatus == VerificationStatus.approved;

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
    DateTime? createdAt,
    bool? isOwner,
    String? address,
    double? rating,
    VerificationStatus? verificationStatus,
    String? selfieWithIdUrl,
    DateTime? verifiedAt,
    String? verificationRejectionReason,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      isOwner: isOwner ?? this.isOwner,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      selfieWithIdUrl: selfieWithIdUrl ?? this.selfieWithIdUrl,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verificationRejectionReason:
          verificationRejectionReason ?? this.verificationRejectionReason,
    );
  }
}