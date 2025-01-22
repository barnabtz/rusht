import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ErrorHandlingService {
  static final ErrorHandlingService _instance = ErrorHandlingService._internal();
  factory ErrorHandlingService() => _instance;
  ErrorHandlingService._internal();

  final _connectivity = Connectivity();
  bool _isOnline = true;
  final _retryDelays = [
    const Duration(seconds: 1),
    const Duration(seconds: 2),
    const Duration(seconds: 4),
    const Duration(seconds: 8),
    const Duration(seconds: 16),
  ];

  Future<void> initialize() async {
    _connectivity.onConnectivityChanged.listen((result) {
      _isOnline = result != ConnectivityResult.none;
    });
    
    final result = await _connectivity.checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
  }

  bool get isOnline => _isOnline;

  Future<T> handleError<T>({
    required Future<T> Function() operation,
    required BuildContext context,
    String? customErrorMessage,
    bool showError = true,
    int maxRetries = 3,
  }) async {
    int retryCount = 0;

    while (true) {
      try {
        return await operation();
      } catch (e) {
        if (retryCount >= maxRetries) {
          final errorMessage = _getErrorMessage(e, customErrorMessage);
          if (showError) {
            _showErrorSnackBar(context, errorMessage);
          }
          rethrow;
        }

        if (e is PostgrestException || e is AuthException) {
          // Database or auth errors - might resolve with retry
          await Future.delayed(_retryDelays[retryCount]);
          retryCount++;
          continue;
        }

        if (!_isOnline) {
          // Network error - wait for connectivity
          await _waitForConnectivity();
          continue;
        }

        // Other errors - show immediately
        final errorMessage = _getErrorMessage(e, customErrorMessage);
        if (showError) {
          _showErrorSnackBar(context, errorMessage);
        }
        rethrow;
      }
    }
  }

  String _getErrorMessage(dynamic error, String? customMessage) {
    if (customMessage != null) return customMessage;

    if (error is PostgrestException) {
      return error.message;
    }

    if (error is AuthException) {
      return error.message;
    }

    if (!_isOnline) {
      return 'No internet connection. Please check your connection and try again.';
    }

    return error.toString();
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _waitForConnectivity() async {
    if (_isOnline) return;

    final completer = Completer<void>();
    late StreamSubscription subscription;

    subscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        completer.complete();
        subscription.cancel();
      }
    });

    return completer.future;
  }

  // Specific error handlers
  Future<T> handleAuthError<T>({
    required Future<T> Function() operation,
    required BuildContext context,
  }) async {
    try {
      return await operation();
    } on AuthException catch (e) {
      String message = 'Authentication failed';
      
      if (e.message.contains('invalid_credentials')) {
        message = 'Invalid email or password';
      } else if (e.message.contains('email_taken')) {
        message = 'Email is already registered';
      }

      _showErrorSnackBar(context, message);
      rethrow;
    }
  }

  Future<T> handleUploadError<T>({
    required Future<T> Function() operation,
    required BuildContext context,
    required String fileName,
  }) async {
    try {
      return await operation();
    } catch (e) {
      final message = 'Failed to upload $fileName: ${_getErrorMessage(e, null)}';
      _showErrorSnackBar(context, message);
      rethrow;
    }
  }

  Future<T> handleDatabaseError<T>({
    required Future<T> Function() operation,
    required BuildContext context,
    required String operation_name,
  }) async {
    try {
      return await operation();
    } on PostgrestException catch (e) {
      final message = 'Failed to $operation_name: ${e.message}';
      _showErrorSnackBar(context, message);
      rethrow;
    }
  }
}
