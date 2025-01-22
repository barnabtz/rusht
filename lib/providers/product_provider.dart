import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/product_model.dart';
import '../services/supabase_service.dart';
import '../services/cloudinary_service.dart';

class ProductProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _searchQuery;
  String? _selectedCategory;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadProducts({
    String? search,
    String? category,
    bool? available,
  }) async {
    try {
      _setLoading(true);
      _searchQuery = search;
      _selectedCategory = category;
      
      final fetchedProducts = await _supabaseService.getProducts(
        search: search,
        category: category,
        available: available,
      );
      
      _products.clear();
      _products.addAll(fetchedProducts);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<ProductModel> createProduct({
    required String title,
    required String description,
    required double pricePerDay,
    required List<XFile> images,
    required String category,
    required String location,
    Map<String, dynamic>? specifications,
  }) async {
    try {
      _setLoading(true);
      
      // Upload images to Cloudinary
      final imageUrls = await _cloudinaryService.uploadImages(images);
      
      if (imageUrls.isEmpty) {
        throw Exception('Failed to upload images');
      }

      final product = ProductModel(
        id: const Uuid().v4(), // Generate a new UUID
        ownerId: Supabase.instance.client.auth.currentUser!.id, // Get current user's ID
        title: title,
        description: description,
        pricePerDay: pricePerDay,
        images: imageUrls,
        category: category,
        location: location,
        createdAt: DateTime.now(),
        specifications: specifications,
      );

      final createdProduct = await _supabaseService.createProduct(product);
      _products.insert(0, createdProduct);
      notifyListeners();
      
      return createdProduct;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      _setLoading(true);
      await _supabaseService.updateProduct(product);
      
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        notifyListeners();
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleAvailability(String productId, bool isAvailable) async {
    try {
      _setLoading(true);
      final index = _products.indexWhere((p) => p.id == productId);
      
      if (index != -1) {
        final product = _products[index].copyWith(isAvailable: isAvailable);
        await _supabaseService.updateProduct(product);
        _products[index] = product;
        notifyListeners();
      }
    } finally {
      _setLoading(false);
    }
  }

  void filterByCategory(String? category) {
    _selectedCategory = category;
    loadProducts(
      search: _searchQuery,
      category: category,
    );
  }

  void search(String? query) {
    _searchQuery = query;
    loadProducts(
      search: query,
      category: _selectedCategory,
    );
  }
}