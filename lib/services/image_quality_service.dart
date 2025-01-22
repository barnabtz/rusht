import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ImageQualityService {
  final _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      enableClassification: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  final _textRecognizer = TextRecognizer();

  Future<ImageQualityResult> checkImageQuality(XFile image) async {
    final File imageFile = File(image.path);
    final imageBytes = await imageFile.readAsBytes();
    final img.Image? decodedImage = img.decodeImage(imageBytes);
    
    if (decodedImage == null) {
      return ImageQualityResult(
        isValid: false,
        errors: ['Failed to decode image'],
      );
    }

    final errors = <String>[];

    // Check image dimensions
    if (decodedImage.width < 1024 || decodedImage.height < 1024) {
      errors.add('Image resolution too low. Minimum 1024x1024 pixels required.');
    }

    // Check file size (500KB - 5MB)
    final sizeInMB = imageBytes.length / (1024 * 1024);
    if (sizeInMB < 0.5) {
      errors.add('Image file size too small. Minimum 500KB required.');
    } else if (sizeInMB > 5) {
      errors.add('Image file size too large. Maximum 5MB allowed.');
    }

    // Check image brightness and contrast
    final brightnessResult = _checkBrightnessAndContrast(decodedImage);
    if (!brightnessResult.isValid) {
      errors.addAll(brightnessResult.errors);
    }

    // Check for faces
    final inputImage = InputImage.fromFile(imageFile);
    final faces = await _faceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      errors.add('No face detected in the image.');
    } else if (faces.length > 1) {
      errors.add('Multiple faces detected. Please show only your face with ID.');
    }

    // Check for text (ID should contain text)
    final recognizedText = await _textRecognizer.processImage(inputImage);
    if (recognizedText.text.isEmpty) {
      errors.add('No text detected. Make sure your ID is clearly visible.');
    }

    return ImageQualityResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  BrightnessResult _checkBrightnessAndContrast(img.Image image) {
    num totalBrightness = 0;
    num minBrightness = 255;
    num maxBrightness = 0;
    final errors = <String>[];

    // Convert to grayscale and calculate brightness
    final grayscale = img.grayscale(image);
    
    for (var y = 0; y < grayscale.height; y++) {
      for (var x = 0; x < grayscale.width; x++) {
        final pixel = grayscale.getPixel(x, y);
        final brightness = img.getLuminance(pixel);
        
        totalBrightness += brightness;
        minBrightness = brightness < minBrightness ? brightness : minBrightness;
        maxBrightness = brightness > maxBrightness ? brightness : maxBrightness;
      }
    }

    final avgBrightness = totalBrightness / (grayscale.width * grayscale.height);
    final contrast = maxBrightness - minBrightness;

    // Check brightness
    if (avgBrightness < 50) {
      errors.add('Image too dark. Please take photo in better lighting.');
    } else if (avgBrightness > 200) {
      errors.add('Image too bright. Please reduce lighting.');
    }

    // Check contrast
    if (contrast < 50) {
      errors.add('Image contrast too low. Please take photo in better lighting.');
    }

    return BrightnessResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  void dispose() {
    _faceDetector.close();
    _textRecognizer.close();
  }
}

class ImageQualityResult {
  final bool isValid;
  final List<String> errors;

  const ImageQualityResult({
    required this.isValid,
    required this.errors,
  });
}

class BrightnessResult {
  final bool isValid;
  final List<String> errors;

  const BrightnessResult({
    required this.isValid,
    required this.errors,
  });
}
