import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../models/booking_model.dart';
import '../providers/auth_provider.dart';
import '../providers/payment_provider.dart';
import '../services/supabase_service.dart';

class BookingSheet extends StatefulWidget {
  final ProductModel product;
  final DateTime startDate;
  final DateTime endDate;

  const BookingSheet({
    super.key,
    required this.product,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<BookingSheet> {
  final _supabaseService = SupabaseService();
  bool _isLoading = false;
  String? _error;

  int get _totalDays => widget.endDate.difference(widget.startDate).inDays + 1;
  double get _totalPrice => widget.product.pricePerDay * _totalDays;

  Future<void> _confirmBooking() async {
    if (!mounted) return;
    
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser?.id;
      final userPhone = authProvider.currentUser?.phoneNumber;
      
      if (userId == null) {
        throw Exception('User not logged in');
      }
      
      if (userPhone == null || userPhone.isEmpty) {
        throw Exception('Please update your phone number in profile settings');
      }

      // Create booking first
      final bookingResponse = await _supabaseService.createBooking(
        productId: widget.product.id,
        renterId: userId,
        startDate: widget.startDate,
        endDate: widget.endDate,
        totalPrice: _totalPrice,
      );

      // Convert the response to BookingModel
      final booking = BookingModel.fromJson(bookingResponse);

      // Initialize payment
      final paymentProvider = context.read<PaymentProvider>();
      await paymentProvider.initiatePayment(
        phoneNumber: userPhone,
        amount: _totalPrice,
        bookingId: booking.id,
      );

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment initiated. Please check your phone for confirmation.'),
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      setState(() => _error = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Booking Details',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ListTile(
            title: Text('Duration'),
            trailing: Text('$_totalDays days'),
          ),
          ListTile(
            title: Text('Price per day'),
            trailing: Text('\$${widget.product.pricePerDay.toStringAsFixed(2)}'),
          ),
          const Divider(),
          ListTile(
            title: Text(
              'Total Price',
              style: theme.textTheme.titleMedium,
            ),
            trailing: Text(
              '\$${_totalPrice.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium,
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _error!,
                style: TextStyle(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _confirmBooking,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Confirm Booking'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
