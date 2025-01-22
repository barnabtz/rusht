import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/verification_status.dart';
import '../services/verification_service.dart';
import '../models/user_model.dart';

class VerificationProvider with ChangeNotifier {
  final VerificationService _verificationService;
  bool _isLoading = false;
  String? _error;
  List<UserModel> _verifications = [];

  VerificationProvider({VerificationService? verificationService})
      : _verificationService = verificationService ?? VerificationService();

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<UserModel> get verifications => _verifications;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<void> loadVerifications(VerificationStatus status) async {
    try {
      _setLoading(true);
      _setError(null);
      _verifications = await _verificationService.getVerifications(status);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> submitVerification(XFile selfieWithId) async {
    try {
      _setLoading(true);
      _setError(null);

      final success = await _verificationService.submitVerification(selfieWithId);
      
      if (!success) {
        _setError('Failed to submit verification. Please try again.');
      }
      
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> approveVerification(String userId) async {
    try {
      _setLoading(true);
      _setError(null);

      final success = await _verificationService.approveVerification(userId);
      
      if (!success) {
        _setError('Failed to approve verification. Please try again.');
      }
      
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> rejectVerification(String userId, String reason) async {
    try {
      _setLoading(true);
      _setError(null);

      final success = await _verificationService.rejectVerification(userId, reason);
      
      if (!success) {
        _setError('Failed to reject verification. Please try again.');
      }
      
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
