import 'package:flutter/material.dart';
import 'package:rusht/models/user_model.dart';
import 'package:rusht/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _initialized = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _initialized;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      // Get the current session
      final session = Supabase.instance.client.auth.currentSession;
      
      if (session != null) {
        // Get user profile from database
        final user = await _supabaseService.getUserProfile(session.user.id);
        if (user != null) {
          _currentUser = user;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    } finally {
      _initialized = true;
      notifyListeners();
    }

    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      switch (event) {
        case AuthChangeEvent.signedIn:
          if (session != null) {
            final user = await _supabaseService.getUserProfile(session.user.id);
            if (user != null) {
              _currentUser = user;
              notifyListeners();
            }
          }
          break;
        case AuthChangeEvent.signedOut:
          _currentUser = null;
          notifyListeners();
          break;
        default:
          break;
      }
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      _setLoading(true);
      _currentUser = await _supabaseService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      notifyListeners();
    } catch (e) {
      _currentUser = null;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _currentUser = await _supabaseService.signIn(
        email: email,
        password: password,
      );
      if (_currentUser == null) {
        throw Exception('Invalid credentials');
      }
      notifyListeners();
    } catch (e) {
      _currentUser = null;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _supabaseService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? address,
    bool? isOwner,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_currentUser == null) {
        throw Exception('No user logged in');
      }

      final updatedUser = _currentUser!.copyWith(
        fullName: fullName,
        phoneNumber: phoneNumber,
        address: address,
        isOwner: isOwner,
      );

      await _supabaseService.updateUserProfile(updatedUser);
      _currentUser = updatedUser;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    try {
      _setLoading(true);
      if (_currentUser != null) {
        final updatedUser = await _supabaseService.getUserProfile(_currentUser!.id);
        _currentUser = updatedUser;
        notifyListeners();
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadProfile() async {
    try {
      if (_currentUser != null) {
        final updatedUser = await _supabaseService.getUserProfile(_currentUser!.id);
        if (updatedUser != null) {
          _currentUser = updatedUser;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }
}
