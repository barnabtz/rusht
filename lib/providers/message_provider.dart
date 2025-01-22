import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../services/supabase_service.dart';

class MessageProvider with ChangeNotifier {
  final _supabaseService = SupabaseService();
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  String? _error;
  String? _currentBookingId;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _messages.where((m) => !m.isRead).length;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadMessages(String bookingId) async {
    if (_currentBookingId != bookingId) {
      _messages = [];
      _currentBookingId = bookingId;
    }

    try {
      _setLoading(true);
      _error = null;
      _messages = await _supabaseService.getMessages(bookingId: bookingId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendMessage({
    required String bookingId,
    required String senderId,
    required String content,
  }) async {
    try {
      await _supabaseService.sendMessage(
        bookingId: bookingId,
        senderId: senderId,
        content: content,
      );
      await loadMessages(bookingId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAsRead(String messageId) async {
    try {
      await _supabaseService.markMessageAsRead(messageId);
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      for (final message in _messages.where((m) => !m.isRead)) {
        await _supabaseService.markMessageAsRead(message.id);
      }
      _messages = _messages.map((m) => m.copyWith(isRead: true)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
