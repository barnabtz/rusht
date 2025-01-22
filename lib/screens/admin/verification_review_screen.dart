import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rusht/models/user_model.dart';
import 'package:rusht/models/verification_status.dart';
import 'package:rusht/providers/verification_provider.dart';
import 'package:rusht/widgets/verification_review_card.dart';

class VerificationReviewScreen extends StatefulWidget {
  const VerificationReviewScreen({super.key});

  @override
  State<VerificationReviewScreen> createState() => _VerificationReviewScreenState();
}

class _VerificationReviewScreenState extends State<VerificationReviewScreen> {
  VerificationStatus _selectedFilter = VerificationStatus.pending;
  bool _isLoading = false;
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVerifications();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadVerifications() async {
    setState(() => _isLoading = true);
    try {
      await context.read<VerificationProvider>().loadVerifications(_selectedFilter);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showRejectDialog(UserModel user) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                hintText: 'Enter rejection reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              _rejectVerification(user);
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Future<void> _rejectVerification(UserModel user) async {
    if (_reasonController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await context.read<VerificationProvider>().rejectVerification(
        user.id,
        _reasonController.text,
      );
      _reasonController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification rejected'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error rejecting verification: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _approveVerification(UserModel user) async {
    setState(() => _isLoading = true);
    try {
      await context.read<VerificationProvider>().approveVerification(user.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification approved'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error approving verification: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Review'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SegmentedButton<VerificationStatus>(
              segments: const [
                ButtonSegment(
                  value: VerificationStatus.pending,
                  label: Text('Pending'),
                ),
                ButtonSegment(
                  value: VerificationStatus.approved,
                  label: Text('Approved'),
                ),
                ButtonSegment(
                  value: VerificationStatus.rejected,
                  label: Text('Rejected'),
                ),
              ],
              selected: {_selectedFilter},
              onSelectionChanged: (Set<VerificationStatus> selected) {
                setState(() => _selectedFilter = selected.first);
                _loadVerifications();
              },
            ),
          ),
        ),
      ),
      body: Consumer<VerificationProvider>(
        builder: (context, provider, child) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final verifications = provider.verifications;
          
          if (verifications.isEmpty) {
            return Center(
              child: Text(
                'No ${_selectedFilter.displayName.toLowerCase()} verifications',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return ListView.builder(
            itemCount: verifications.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final user = verifications[index];
              return VerificationReviewCard(
                user: user,
                onApprove: () => _approveVerification(user),
                onReject: () => _showRejectDialog(user),
              );
            },
          );
        },
      ),
    );
  }
}
