import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../chat/chat_screen.dart';
import '../../models/booking_model.dart';

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Booking'),
        content: TextField(
          controller: _reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason for rejection',
            hintText: 'Please provide a reason for rejecting this booking',
          ),
          maxLines: null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final reason = _reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason for rejection'),
                  ),
                );
                return;
              }
              Navigator.pop(context);
              _rejectBooking(reason);
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptBooking() async {
    try {
      await context.read<BookingProvider>().acceptBooking(widget.bookingId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking accepted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accepting booking: $e')),
        );
      }
    }
  }

  Future<void> _rejectBooking(String reason) async {
    try {
      await context
          .read<BookingProvider>()
          .rejectBooking(widget.bookingId, reason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking rejected successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting booking: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(bookingId: widget.bookingId),
                ),
              );
            },
            tooltip: 'Chat',
          ),
        ],
      ),
      body: Consumer<BookingProvider>(
        builder: (context, provider, child) {
          final booking = provider.bookings.isEmpty
            ? null
            : provider.bookings.firstWhere(
                (b) => b.id == widget.bookingId,
                orElse: () => provider.bookings.first,
              );

          if (booking == null) {
            return const Center(child: Text('Booking not found'));
          }

          final isOwner = currentUser?.isOwner == true &&
              booking.renterId == currentUser?.id;
          final isPending = booking.status == BookingStatus.pending;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: ${booking.status.displayName}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: _getStatusColor(context, booking.status),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _DetailRow(
                        label: 'Start Date',
                        value: booking.startDate.toString(),
                      ),
                      const SizedBox(height: 8),
                      _DetailRow(
                        label: 'End Date',
                        value: booking.endDate.toString(),
                      ),
                      if (booking.cancellationReason != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Cancellation Reason:',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(booking.cancellationReason!),
                      ],
                    ],
                  ),
                ),
              ),
              if (isOwner && isPending) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showRejectDialog,
                        icon: const Icon(Icons.close),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _acceptBooking,
                        icon: const Icon(Icons.check),
                        label: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Color _getStatusColor(BuildContext context, BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.active:
        return Colors.blue;
      case BookingStatus.completed:
        return Colors.purple;
      case BookingStatus.cancelled:
      case BookingStatus.declined:
        return Theme.of(context).colorScheme.error;
      default:
        return Colors.grey;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
