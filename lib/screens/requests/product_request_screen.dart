import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/product_request_model.dart';
import '../../providers/product_request_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';

class ProductRequestScreen extends StatefulWidget {
  const ProductRequestScreen({super.key});

  @override
  State<ProductRequestScreen> createState() => _ProductRequestScreenState();
}

class _ProductRequestScreenState extends State<ProductRequestScreen> {
  String? _selectedCategory;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId != null) {
      final requestProvider = context.read<ProductRequestProvider>();
      await requestProvider.checkRequestEligibility(userId);
      await requestProvider.loadRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Consumer<ProductRequestProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingView();
          }

          if (provider.error != null) {
            return ErrorView(
              message: provider.error!,
              onRetry: _loadData,
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search requests...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: (value) {
                        provider.loadRequests(
                          category: _selectedCategory,
                          search: value.isNotEmpty ? value : null,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        hintText: 'Filter by category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Categories'),
                        ),
                        ...['Electronics', 'Furniture', 'Tools', 'Sports'].map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
                        provider.loadRequests(
                          category: value,
                          search: _searchController.text.isNotEmpty
                              ? _searchController.text
                              : null,
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (!provider.canCreateRequests) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Complete 15 bookings to unlock product requests',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Expanded(
                child: provider.requests.isEmpty
                    ? Center(
                        child: Text(
                          'No requests found',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.requests.length,
                        itemBuilder: (context, index) {
                          final request = provider.requests[index];
                          return _RequestCard(request: request);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<ProductRequestProvider>(
        builder: (context, provider, child) {
          if (!provider.canCreateRequests) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton.extended(
            onPressed: () => _showCreateRequestDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('New Request'),
          );
        },
      ),
    );
  }

  void _showCreateRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _CreateRequestDialog(),
    ).then((created) {
      if (created == true) {
        _loadData();
      }
    });
  }
}

class _CreateRequestDialog extends StatefulWidget {
  const _CreateRequestDialog();

  @override
  State<_CreateRequestDialog> createState() => _CreateRequestDialogState();
}

class _CreateRequestDialogState extends State<_CreateRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetMinController = TextEditingController();
  final _budgetMaxController = TextEditingController();
  String? _selectedCategory;
  DateTime? _neededBy;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Request'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a title' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a description' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['Electronics', 'Furniture', 'Tools', 'Sports']
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
              ),
              TextFormField(
                controller: _budgetMinController,
                decoration: const InputDecoration(labelText: 'Minimum Budget'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a minimum budget' : null,
              ),
              TextFormField(
                controller: _budgetMaxController,
                decoration: const InputDecoration(labelText: 'Maximum Budget'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a maximum budget' : null,
              ),
              ListTile(
                title: Text(
                  'Needed By: ${_neededBy != null ? DateFormat('MMM dd, yyyy').format(_neededBy!) : 'Not set'}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    setState(() => _neededBy = picked);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (_neededBy == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select a date')),
                );
                return;
              }
              _createRequest();
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _createRequest() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    final request = ProductRequestModel(
      id: '', // The server will generate the ID
      requesterId: userId,
      title: _titleController.text,
      description: _descriptionController.text,
      category: _selectedCategory!,
      budgetMin: double.parse(_budgetMinController.text),
      budgetMax: double.parse(_budgetMaxController.text),
      neededBy: _neededBy!,
      createdAt: DateTime.now(),
    );

    try {
      await context.read<ProductRequestProvider>().createRequest(request);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating request: $e')),
        );
      }
    }
  }
}

class _RequestCard extends StatelessWidget {
  final ProductRequestModel request;

  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final daysLeft = request.neededBy.difference(DateTime.now()).inDays;
    final isUrgent = daysLeft <= 3;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Urgent',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              request.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Budget: \$${request.budgetMin.toStringAsFixed(2)} - \$${request.budgetMax.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Needed by: ${DateFormat('MMM dd').format(request.neededBy)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            if (request.images.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: request.images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          request.images[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
