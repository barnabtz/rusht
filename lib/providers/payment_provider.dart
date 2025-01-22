import 'package:flutter/foundation.dart';
import 'package:rusht/services/payment_service.dart';

class PaymentProvider with ChangeNotifier {
  final PaymentService _paymentService;
  bool _isLoading = false;
  String? _error;

  PaymentProvider() : _paymentService = PaymentService();

  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<Map<String, dynamic>> initiatePayment({
    required String phoneNumber,
    required double amount,
    required String bookingId,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final response = await _paymentService.initiatePayment(
        phoneNumber: phoneNumber,
        amount: amount,
        bookingId: bookingId,
      );

      notifyListeners();
      return response;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> checkPaymentStatus(String transactionId) async {
    try {
      _setLoading(true);
      _error = null;

      final status = await _paymentService.checkTransactionStatus(transactionId);
      
      notifyListeners();
      return status;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> processSplitPayment({
    required String transactionId,
    required String ownerAccountId,
    required double amount,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      await _paymentService.processSplitPayment(
        transactionId: transactionId,
        ownerPhoneNumber: ownerAccountId,
        amount: amount,
      );

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
