import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

class ValidationService {
  static final ValidationService _instance = ValidationService._internal();
  factory ValidationService() => _instance;
  ValidationService._internal();

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!EmailValidator.validate(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(value.trim())) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value.trim());
    if (price == null || price <= 0) {
      return 'Please enter a valid price';
    }
    return null;
  }

  String? validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null) {
      return 'Start date is required';
    }
    if (endDate == null) {
      return 'End date is required';
    }
    if (startDate.isAfter(endDate)) {
      return 'Start date must be before end date';
    }
    if (startDate.isBefore(DateTime.now())) {
      return 'Start date cannot be in the past';
    }
    return null;
  }

  String? validateImages(List<String>? images, {int minImages = 1, int maxImages = 5}) {
    if (images == null || images.isEmpty) {
      return 'At least $minImages image is required';
    }
    if (images.length > maxImages) {
      return 'Maximum $maxImages images allowed';
    }
    return null;
  }

  String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL is required';
    }
    if (!Uri.tryParse(value.trim())!.hasAbsolutePath) {
      return 'Please enter a valid URL';
    }
    return null;
  }
}
