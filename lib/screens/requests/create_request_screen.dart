import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rusht/l10n/app_localizations.dart';
import 'package:rusht/models/product_request_model.dart';
import 'package:rusht/providers/product_request_provider.dart';
import 'package:rusht/providers/auth_provider.dart';
import 'package:rusht/services/cloudinary_service.dart';


class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetMinController = TextEditingController();
  final _budgetMaxController = TextEditingController();
  final _cloudinary = CloudinaryService();
  
  String _selectedCategory = 'electronics';
  DateTime? _neededBy;
  final List<String> _images = [];
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null) {
      setState(() => _neededBy = date);
    }
  }

  Future<void> _uploadImage() async {
    try {
      setState(() => _isLoading = true);
      
      // Use ImagePicker to select an image
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final imageUrl = await _cloudinary.uploadImage(image);
        if (imageUrl != null && mounted) {
          setState(() => _images.add(imageUrl));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_error ?? 'Failed to upload image'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId == null) return;

      final request = ProductRequestModel(
        id: '',  // Will be set by Supabase
        requesterId: userId,
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        budgetMin: double.parse(_budgetMinController.text),
        budgetMax: double.parse(_budgetMaxController.text),
        neededBy: _neededBy!,
        createdAt: DateTime.now(),
        images: _images,
      );

      await context.read<ProductRequestProvider>().createRequest(request);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request created successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_error ?? 'Failed to create request'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createRequest),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => _error = null),
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ],
                    ),
                  ),

                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: l10n.requestTitle,
                    hintText: l10n.requestTitleHint,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.requestTitleRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: l10n.requestDescription,
                    hintText: l10n.requestDescriptionHint,
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.requestDescriptionRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: l10n.requestCategory,
                  ),
                  items: [
                    'electronics',
                    'furniture',
                    'tools',
                    'sports'
                  ].map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(
                          category == 'electronics' ? l10n.categoryElectronics :
                          category == 'furniture' ? l10n.categoryFurniture :
                          category == 'tools' ? l10n.categoryTools :
                          l10n.categorySports
                        ),
                      ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _budgetMinController,
                        decoration: InputDecoration(
                          labelText: l10n.requestBudgetMin,
                          prefixText: '\$',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.requestBudgetRequired;
                          }
                          if (double.tryParse(value) == null) {
                            return l10n.requestBudgetInvalid;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _budgetMaxController,
                        decoration: InputDecoration(
                          labelText: l10n.requestBudgetMax,
                          prefixText: '\$',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.requestBudgetRequired;
                          }
                          if (double.tryParse(value) == null) {
                            return l10n.requestBudgetInvalid;
                          }
                          final min = double.tryParse(_budgetMinController.text);
                          final max = double.tryParse(value);
                          if (min != null && max != null && max <= min) {
                            return l10n.requestBudgetMaxTooLow;
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                ListTile(
                  title: Text(
                    _neededBy == null
                        ? l10n.requestNeededBy
                        : l10n.requestNeededByDate.replaceAll(
                            '{date}',
                            DateFormat('MMM dd, yyyy').format(_neededBy!),
                          ),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _selectDate,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Text(l10n.requestImages),
                    const Spacer(),
                    if (_images.length < 3)
                      TextButton.icon(
                        onPressed: _isLoading ? null : _uploadImage,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: Text(l10n.requestAddImage),
                      ),
                  ],
                ),
                if (_images.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 8,
                                top: 8,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _images[index],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton(
                                icon: const Icon(Icons.remove_circle),
                                color: Colors.red,
                                onPressed: () {
                                  setState(() => _images.removeAt(index));
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitRequest,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.submitRequest),
          ),
        ),
      ),
    );
  }
}
