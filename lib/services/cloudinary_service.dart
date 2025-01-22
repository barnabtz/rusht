import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;

  late final CloudinaryPublic _cloudinary;
  bool _isInitialized = false;

  CloudinaryService._internal();

  void initialize() {
    if (_isInitialized) return;

    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

    if (cloudName == null || uploadPreset == null) {
      throw Exception(
        'Cloudinary credentials not found. Please check your .env file:\n'
        'CLOUDINARY_CLOUD_NAME=$cloudName\n'
        'CLOUDINARY_UPLOAD_PRESET=$uploadPreset'
      );
    }

    print('Initializing Cloudinary with:\n'
          'Cloud Name: $cloudName\n'
          'Upload Preset: $uploadPreset');

    _cloudinary = CloudinaryPublic(cloudName, uploadPreset, cache: false);
    _isInitialized = true;
  }

  Future<String?> uploadImage(XFile image) async {
    if (!_isInitialized) {
      initialize();
    }

    try {
      // Create a File object from the XFile path
      final file = File(image.path);
      
      // Ensure the file exists
      if (!await file.exists()) {
        print('Error: File does not exist at path: ${image.path}');
        return null;
      }

      // Get file size and type
      final fileSize = await file.length();
      final fileExtension = image.path.split('.').last.toLowerCase();
      
      print('Uploading file:\n'
            'Path: ${image.path}\n'
            'Size: $fileSize bytes\n'
            'Type: $fileExtension');

      // Validate file type
      if (!['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension)) {
        print('Error: Invalid file type. Only jpg, jpeg, png, and gif are supported.');
        return null;
      }

      // Validate file size (max 10MB)
      if (fileSize > 10 * 1024 * 1024) {
        print('Error: File too large. Maximum size is 10MB.');
        return null;
      }

      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          folder: 'rusht',
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      print('Upload successful!\n'
            'Public ID: ${response.publicId}\n'
            'URL: ${response.secureUrl}');
            
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      print('Cloudinary upload error:\n'
            'Message: ${e.message}\n'
            'Code: ${e.statusCode}');
            
      if (e.message?.contains('preset') ?? false) {
        print('Upload preset error: Check if preset "rusht_upload" is:\n'
              '1. Created in Cloudinary console\n'
              '2. Set to "Unsigned"\n'
              '3. Enabled for use');
      }
      return null;
    } catch (e, stackTrace) {
      print('Unexpected error during upload:\n'
            'Error: $e\n'
            'Stack trace: $stackTrace');
      return null;
    }
  }

  Future<List<String>> uploadImages(List<XFile> images) async {
    final urls = <String>[];
    
    for (final image in images) {
      try {
        final url = await uploadImage(image);
        if (url != null) {
          urls.add(url);
        } else {
          print('Failed to upload image: ${image.path}');
        }
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
    
    if (urls.isEmpty) {
      print('Warning: No images were successfully uploaded');
    } else {
      print('Successfully uploaded ${urls.length} of ${images.length} images');
    }
    
    return urls;
  }

  String getOptimizedImageUrl(
    String originalUrl, {
    int? width,
    int? height,
    bool thumbnail = false,
  }) {
    try {
      // Extract the public ID from the original URL
      final uri = Uri.parse(originalUrl);
      final pathSegments = uri.pathSegments;
      final publicId =
          pathSegments.sublist(pathSegments.indexOf('rusht')).join('/');

      // Build transformation URL
      final transformations = [];

      // Add quality and format
      transformations.add('q_85');
      transformations.add('f_auto');

      if (thumbnail) {
        transformations.add('c_fill,w_200,h_200');
      } else if (width != null || height != null) {
        final dimensions = [];
        if (width != null) dimensions.add('w_$width');
        if (height != null) dimensions.add('h_$height');
        transformations.add('c_scale,${dimensions.join(",")}');
      }

      // Construct the transformed URL
      final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
      if (cloudName == null) return originalUrl;

      return 'https://res.cloudinary.com/$cloudName/image/upload/${transformations.join(",")}/$publicId';
    } catch (e) {
      print('Error generating optimized URL: $e');
      return originalUrl;
    }
  }
}
