import 'package:flutter/foundation.dart';
import '../models/product_request_model.dart';
import '../services/product_request_service.dart';

class ProductRequestProvider with ChangeNotifier {
  final _requestService = ProductRequestService();
  List<ProductRequestModel> _requests = [];
  bool _isLoading = false;
  String? _error;
  bool _canCreateRequests = false;

  List<ProductRequestModel> get requests => _requests;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get canCreateRequests => _canCreateRequests;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> checkRequestEligibility(String userId) async {
    try {
      _setLoading(true);
      _error = null;
      _canCreateRequests = await _requestService.canCreateRequests(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadRequests({String? category, String? search}) async {
    try {
      _setLoading(true);
      _error = null;
      _requests = await _requestService.getRequests(
        category: category,
        search: search,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createRequest(ProductRequestModel request) async {
    try {
      _setLoading(true);
      _error = null;
      await _requestService.createRequest(request);
      await loadRequests();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markRequestFulfilled(String requestId) async {
    try {
      _setLoading(true);
      _error = null;
      await _requestService.markRequestFulfilled(requestId);
      await loadRequests();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteRequest(String requestId) async {
    try {
      _setLoading(true);
      _error = null;
      await _requestService.deleteRequest(requestId);
      await loadRequests();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }
}
