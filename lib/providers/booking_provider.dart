import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../services/supabase_service.dart';

class BookingProvider with ChangeNotifier {
  final _supabaseService = SupabaseService();
  List<BookingModel> _bookings = [];
  bool _isLoading = false;
  String? _error;

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadBookings({required String userId, bool isOwner = false}) async {
    try {
      _setLoading(true);
      _error = null;
      _bookings = await _supabaseService.getBookings(userId: userId, asRenter: !isOwner)
          .then((bookingMaps) => bookingMaps.map((bookingMap) => BookingModel.fromJson(bookingMap)).toList());
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createBooking(BookingModel booking) async {
    try {
      _setLoading(true);
      _error = null;
      await _supabaseService.createBooking(
        productId: booking.productId,
        renterId: booking.renterId,
        startDate: booking.startDate,
        endDate: booking.endDate,
        totalPrice: booking.totalPrice
      );
      await loadBookings(userId: booking.renterId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> acceptBooking(String bookingId) async {
    try {
      _setLoading(true);
      _error = null;
      await _supabaseService.acceptBooking(bookingId);
      final booking = _bookings.firstWhere((b) => b.id == bookingId);
      await loadBookings(userId: booking.ownerId, isOwner: true);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> rejectBooking(String bookingId, String reason) async {
    try {
      _setLoading(true);
      _error = null;
      await _supabaseService.rejectBooking(bookingId, reason);
      final booking = _bookings.firstWhere((b) => b.id == bookingId);
      await loadBookings(userId: booking.ownerId, isOwner: true);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required BookingStatus status,
    String? cancellationReason,
  }) async {
    try {
      _setLoading(true);
      _error = null;
      await _supabaseService.updateBookingStatus(
        bookingId: bookingId,
        status: status.name,
        cancellationReason: cancellationReason,
      );
      final booking = _bookings.firstWhere((b) => b.id == bookingId);
      await loadBookings(
        userId: booking.ownerId,
        isOwner: true,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }
}
