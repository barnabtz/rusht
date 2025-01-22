import 'package:flutter/material.dart';
import 'package:rusht/models/user_model.dart';
import 'package:rusht/models/verification_status.dart';
import 'package:rusht/widgets/verification_image_viewer.dart';

class VerificationReviewCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const VerificationReviewCard({
    super.key,
    required this.user,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Header
          ListTile(
            leading: CircleAvatar(
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null
                  ? Text(
                      user.fullName?.isNotEmpty == true
                          ? user.fullName![0].toUpperCase()
                          : user.email[0].toUpperCase(),
                    )
                  : null,
            ),
            title: Text(user.fullName ?? 'No name'),
            subtitle: Text(user.email),
            trailing: _buildStatusChip(context),
          ),
          // Verification Image
          if (user.selfieWithIdUrl != null)
            GestureDetector(
              onTap: () => _showImageViewer(context),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(user.selfieWithIdUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.zoom_in,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          // Action Buttons
          if (user.verificationStatus == VerificationStatus.pending)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: onApprove,
                    child: const Text('Approve'),
                  ),
                ],
              ),
            ),
          // Rejection Reason
          if (user.verificationStatus == VerificationStatus.rejected &&
              user.verificationRejectionReason != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rejection Reason:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(user.verificationRejectionReason!),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color backgroundColor;
    Color textColor = Theme.of(context).colorScheme.onPrimary;
    String text = user.verificationStatus.displayName;

    switch (user.verificationStatus) {
      case VerificationStatus.approved:
        backgroundColor = Theme.of(context).colorScheme.primary;
        break;
      case VerificationStatus.pending:
        backgroundColor = Theme.of(context).colorScheme.tertiary;
        break;
      case VerificationStatus.rejected:
        backgroundColor = Theme.of(context).colorScheme.error;
        break;
      case VerificationStatus.unverified:
        backgroundColor = Theme.of(context).colorScheme.surfaceVariant;
        textColor = Theme.of(context).colorScheme.onSurfaceVariant;
        break;
    }

    return Chip(
      label: Text(text),
      backgroundColor: backgroundColor,
      labelStyle: TextStyle(color: textColor),
    );
  }

  void _showImageViewer(BuildContext context) {
    if (user.selfieWithIdUrl == null) return;

    showDialog(
      context: context,
      builder: (context) => VerificationImageViewer(
        imageUrl: user.selfieWithIdUrl!,
        userName: user.fullName ?? 'No name',
      ),
    );
  }
}
