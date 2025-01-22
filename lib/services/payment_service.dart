import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PaymentService {
  final String apiKey;
  final String apiSecret;
  final String consumerKey;
  final String baseUrl;
  final double platformFeePercentage;
  
  // API endpoints
  static const String _transactionsEndpoint = '/transactions';
  static const String _accountsEndpoint = '/accounts';

  PaymentService()
      : apiKey = dotenv.env['GSMA_API_KEY'] ?? '',
        apiSecret = dotenv.env['GSMA_API_SECRET'] ?? '',
        consumerKey = dotenv.env['GSMA_API_CONSUMER_KEY'] ?? '',
        baseUrl = dotenv.env['GSMA_API_BASE_URL'] ?? 'https://api.mobilemoneyapi.io/v1.2',
        platformFeePercentage = double.parse(dotenv.env['PLATFORM_FEE_PERCENTAGE'] ?? '10') / 100;

  Future<Map<String, dynamic>> initiatePayment({
    required String phoneNumber,
    required double amount,
    required String bookingId,
  }) async {
    try {
      final platformFee = amount * platformFeePercentage;
      final totalAmount = amount + platformFee;

      final headers = _getAuthHeaders();

      final body = {
        'amount': totalAmount.toString(),
        'currency': dotenv.env['DEFAULT_CURRENCY'] ?? 'USD',
        'payer': {
          'partyIdType': 'MSISDN',
          'partyId': phoneNumber
        },
        'payerMessage': 'Payment for booking $bookingId',
        'payeeNote': 'Rental payment including platform fee',
        'externalId': bookingId,
        'callbackUrl': '${dotenv.env['APP_URL']}/api/payments/callback'
      };

      final response = await http.post(
        Uri.parse('$baseUrl$_transactionsEndpoint'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        final responseData = json.decode(response.body);
        return {
          ...responseData,
          'platformFee': platformFee,
          'netAmount': amount,
        };
      } else {
        throw Exception('Payment initiation failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Payment initiation failed: $e');
    }
  }

  Future<Map<String, dynamic>> checkTransactionStatus(String transactionId) async {
    try {
      final headers = _getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl$_transactionsEndpoint/$transactionId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to check transaction status: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to check transaction status: $e');
    }
  }

  Future<void> processSplitPayment({
    required String transactionId,
    required String ownerPhoneNumber,
    required double amount,
  }) async {
    try {
      final platformFee = amount * platformFeePercentage;
      final ownerAmount = amount - platformFee;

      // Transfer the owner's share
      await _transferAmount(
        amount: ownerAmount,
        recipientId: ownerPhoneNumber,
        description: 'Rental payment for transaction $transactionId',
      );

      // Transfer the platform fee
      await _recordPlatformFee(
        transactionId: transactionId,
        amount: platformFee,
      );
    } catch (e) {
      throw Exception('Failed to process split payment: $e');
    }
  }

  Future<void> _transferAmount({
    required double amount,
    required String recipientId,
    required String description,
  }) async {
    final headers = _getAuthHeaders();

    final body = {
      'amount': amount.toString(),
      'currency': dotenv.env['DEFAULT_CURRENCY'] ?? 'USD',
      'payee': {
        'partyIdType': 'MSISDN',
        'partyId': recipientId
      },
      'payeeNote': description,
    };

    final response = await http.post(
      Uri.parse('$baseUrl$_transactionsEndpoint/transfer'),
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 202) {
      throw Exception('Transfer failed: ${response.body}');
    }
  }

  Future<void> _recordPlatformFee({
    required String transactionId,
    required double amount,
  }) async {
    final platformPhoneNumber = dotenv.env['PLATFORM_PHONE_NUMBER'];
    if (platformPhoneNumber == null) {
      throw Exception('Platform phone number not configured');
    }

    await _transferAmount(
      amount: amount,
      recipientId: platformPhoneNumber,
      description: 'Platform fee for transaction $transactionId',
    );
  }

  Map<String, String> _getAuthHeaders() {
    final basicAuth = base64Encode(utf8.encode('$apiKey:$apiSecret'));
    return {
      'Authorization': 'Basic $basicAuth',
      'Content-Type': 'application/json',
      'X-Date': DateTime.now().toUtc().toIso8601String(),
    };
  }
}
