import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';
import '../../models/product_model.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const BookingCard({
    super.key,
    required this.booking,
    required this.product,
    this.onTap,
    this.onCancel,
    this.onAccept,
    this.onDecline,
  });

  Color _getStatusColor(BuildContext context) {
    switch (booking.status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Theme.of(context).colorScheme.primary;
      case BookingStatus.active:
        return Colors.green;
      case BookingStatus.cancelled:
        return Theme.of(context).colorScheme.error;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.declined:
        return Theme.of(context).colorScheme.error;
    }
  }

  String _getStatusText() {
    switch (booking.status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.active:
        return 'Active';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.declined:
        return 'Declined';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: product.images.isNotEmpty ? product.images.first : '',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${booking.totalPrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${dateFormat.format(booking.startDate)} - ${dateFormat.format(booking.endDate)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(context).withAlpha(25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          booking.status == BookingStatus.pending
                              ? Icons.access_time
                              : booking.status == BookingStatus.confirmed
                                  ? Icons.check_circle
                                  : booking.status == BookingStatus.cancelled
                                      ? Icons.cancel
                                      : booking.status == BookingStatus.completed
                                          ? Icons.task_alt
                                          : Icons.cancel,
                          size: 16,
                          color: _getStatusColor(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusText(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _getStatusColor(context),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (booking.status == BookingStatus.pending) ...[
                    if (onDecline != null)
                      TextButton(
                        onPressed: onDecline,
                        child: const Text('Decline'),
                      ),
                    if (onAccept != null)
                      FilledButton(
                        onPressed: onAccept,
                        child: const Text('Accept'),
                      ),
                  ] else if (booking.status == BookingStatus.confirmed &&
                      onCancel != null) ...[
                    TextButton(
                      onPressed: onCancel,
                      child: const Text('Cancel'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
