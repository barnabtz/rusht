import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rusht/providers/auth_provider.dart';
import 'package:rusht/services/cloudinary_service.dart';
import 'package:rusht/services/location_service.dart';
import 'package:rusht/widgets/custom_text_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rusht/providers/product_provider.dart';
import 'package:rusht/widgets/user_products_list.dart';
import 'package:rusht/widgets/add_product_modal.dart';
import 'package:rusht/models/verification_status.dart';
import 'package:rusht/providers/verification_provider.dart';
import 'package:rusht/widgets/verification_camera_modal.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _locationService = LocationService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  late final TabController _tabController;
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProducts();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadUserProfile() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      setState(() {
        _fullNameController.text = user.fullName ?? '';
        _phoneController.text = user.phoneNumber ?? '';
        _addressController.text = user.address ?? '';
      });
    }
  }

  Future<void> _loadUserProducts() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId != null) {
      await context.read<ProductProvider>().loadProducts(
        available: null,
        search: null,
        category: null,
      );
    }
  }

  void _showAddProductModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const AddProductModal(),
    ).then((_) => _loadUserProducts());
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _isLocating = true);
      
      // Get current address
      final address = await _locationService.getCurrentAddress();
      
      setState(() {
        _addressController.text = address;
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.locationUpdated ?? 'Location updated successfully'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _isLoading = true);
        
        final url = await _cloudinaryService.uploadImage(image);

        if (url != null) {
          if (!mounted) return;
          
          final userId = context.read<AuthProvider>().currentUser?.id;
          if (userId == null) return;

          await Supabase.instance.client
              .from('profiles')
              .update({'avatar_url': url})
              .eq('id', userId);

          // Reload profile in AuthProvider to update UI
          await context.read<AuthProvider>().loadProfile();

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)?.profilePictureUpdated ?? 'Profile picture updated successfully'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile picture: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        setState(() => _isLoading = true);
        
        await context.read<AuthProvider>().updateProfile(
          fullName: _fullNameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          isOwner: context.read<AuthProvider>().currentUser?.isOwner ?? false,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.profileUpdated ?? 'Profile updated successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        setState(() => _isEditing = false);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final l10n = AppLocalizations.of(context);

    if (user == null || l10n == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: l10n.editProfile,
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() => _isEditing = false);
                _loadUserProfile();
              },
              tooltip: l10n.cancel,
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Profile'),
            Tab(text: 'My Products'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: user.avatarUrl != null
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                        child: user.avatarUrl == null
                            ? Text(
                                user.fullName?.isNotEmpty == true
                                    ? user.fullName![0].toUpperCase()
                                    : user.email[0].toUpperCase(),
                                style: Theme.of(context).textTheme.headlineMedium,
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: IconButton.filledTonal(
                          onPressed: _isLoading ? null : _pickAndUploadImage,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.camera_alt),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                user.isVerified
                                    ? Icons.verified_user
                                    : Icons.gpp_maybe_outlined,
                                color: user.isVerified
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ID Verification',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Spacer(),
                              _buildVerificationStatusChip(context, user.verificationStatus),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getVerificationMessage(user.verificationStatus),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (user.verificationStatus == VerificationStatus.rejected &&
                              user.verificationRejectionReason != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Reason: ${user.verificationRejectionReason}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          if (user.verificationStatus.canSubmitVerification)
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _startVerification,
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Verify with ID'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _fullNameController,
                    label: l10n.fullName,
                    enabled: _isEditing,
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.fullNameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _phoneController,
                    label: l10n.phoneNumber,
                    enabled: _isEditing,
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _addressController,
                    label: l10n.address,
                    enabled: _isEditing,
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    suffixIcon: _isEditing
                        ? IconButton(
                            onPressed: _isLocating ? null : _getCurrentLocation,
                            icon: _isLocating
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.my_location),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(l10n.iAmOwner),
                    subtitle: Text(l10n.ownerDescription),
                    value: user.isOwner,
                    onChanged: _isEditing
                        ? (value) async {
                            try {
                              setState(() => _isLoading = true);
                              await context.read<AuthProvider>().updateProfile(
                                fullName: _fullNameController.text.trim(),
                                phoneNumber: _phoneController.text.trim(),
                                address: _addressController.text.trim(),
                                isOwner: value,
                              );
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(value
                                      ? l10n.ownerModeEnabled
                                      : l10n.ownerModeDisabled),
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error updating owner status: $e'),
                                  backgroundColor: Theme.of(context).colorScheme.error,
                                ),
                              );
                            } finally {
                              if (mounted) {
                                setState(() => _isLoading = false);
                              }
                            }
                          }
                        : null,
                  ),
                  const SizedBox(height: 24),
                  if (_isEditing)
                    FilledButton(
                      onPressed: _isLoading ? null : _updateProfile,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(l10n.saveChanges),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Consumer<ProductProvider>(
            builder: (context, provider, child) {
              final userProducts = provider.products
                  .where((p) => p.ownerId == user.id)
                  .toList();

              return UserProductsList(
                userId: user.id,
                isLoading: provider.isLoading,
                products: userProducts,
                onAddProduct: _showAddProductModal,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStatusChip(BuildContext context, VerificationStatus status) {
    Color backgroundColor;
    Color textColor = Theme.of(context).colorScheme.onPrimary;
    String text = status.displayName;

    switch (status) {
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

  String _getVerificationMessage(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.approved:
        return 'Your identity has been verified. You can now use all features of the app.';
      case VerificationStatus.pending:
        return 'Your verification is under review. This usually takes 1-2 business days.';
      case VerificationStatus.rejected:
        return 'Your verification was not approved. Please try again with a clearer photo.';
      case VerificationStatus.unverified:
        return 'Verify your identity to unlock all features and build trust with other users.';
    }
  }

  Future<void> _startVerification() async {
    final result = await showModalBottomSheet<XFile?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const VerificationCameraModal(),
    );

    if (result != null && mounted) {
      // Upload verification photo
      setState(() => _isLoading = true);
      try {
        await context.read<VerificationProvider>().submitVerification(result);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting verification: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}