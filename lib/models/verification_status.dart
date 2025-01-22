enum VerificationStatus {
  unverified,
  pending,
  approved,
  rejected;

  String get displayName {
    switch (this) {
      case VerificationStatus.unverified:
        return 'Unverified';
      case VerificationStatus.pending:
        return 'Pending Review';
      case VerificationStatus.approved:
        return 'Verified';
      case VerificationStatus.rejected:
        return 'Verification Failed';
    }
  }

  bool get canSubmitVerification {
    return this == VerificationStatus.unverified || 
           this == VerificationStatus.rejected;
  }
}
