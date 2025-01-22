import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_request_model.dart';

class ProductRequestService {
  final _client = Supabase.instance.client;

  Future<bool> canCreateRequests(String userId) async {
    try {
      final response = await _client
          .from('bookings')
          .select('id')
          .eq('renter_id', userId)
          .eq('status', 'completed')
          .count();

      final completedBookings = response.count;
      return completedBookings >= 15;
    } catch (e) {
      throw Exception('Failed to check request eligibility: $e');
    }
  }

  Future<List<ProductRequestModel>> getRequests({
    String? category,
    String? search,
  }) async {
    try {
      var query = _client
          .from('product_requests')
          .select('''
            *,
            requester:profiles!product_requests_requester_id_fkey(*)
          ''')
          .eq('status', RequestStatus.open.name)
          .gte('needed_by', DateTime.now().toIso8601String());

      if (category != null) {
        query = query.eq('category', category);
      }
      if (search != null) {
        query = query.or('title.ilike.%$search%,description.ilike.%$search%');
      }

      final response = await query.order('created_at', ascending: false);
      return (response as List)
          .map((item) => ProductRequestModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to get product requests: $e');
    }
  }

  Future<ProductRequestModel> createRequest(ProductRequestModel request) async {
    try {
      // Check if user is eligible
      final canCreate = await canCreateRequests(request.requesterId);
      if (!canCreate) {
        throw Exception('You need at least 15 completed bookings to create requests');
      }

      // Check active requests count
      final activeCount = await _client
          .from('product_requests')
          .select('id')
          .eq('requester_id', request.requesterId)
          .eq('status', RequestStatus.open.name)
          .count();

      if (activeCount.count >= 3) {
        throw Exception('You can only have 3 active requests at a time');
      }

      // Create request
      final response = await _client
          .from('product_requests')
          .insert(request.toJson())
          .select()
          .single();

      return ProductRequestModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create product request: $e');
    }
  }

  Future<void> markRequestFulfilled(String requestId) async {
    try {
      await _client
          .from('product_requests')
          .update({'status': RequestStatus.fulfilled.name})
          .eq('id', requestId);
    } catch (e) {
      throw Exception('Failed to mark request as fulfilled: $e');
    }
  }

  Future<void> deleteRequest(String requestId) async {
    try {
      await _client
          .from('product_requests')
          .delete()
          .eq('id', requestId);
    } catch (e) {
      throw Exception('Failed to delete product request: $e');
    }
  }
}
