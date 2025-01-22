import 'package:image_picker/image_picker.dart';
import 'package:rusht/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/verification_status.dart';
import 'cloudinary_service.dart';
import 'supabase_service.dart';

class VerificationService {
  final CloudinaryService _cloudinaryService;
  final SupabaseService _supabaseService;

  late final SupabaseClient _client;

  VerificationService({
    CloudinaryService? cloudinaryService,
    SupabaseService? supabaseService,
  })  : _cloudinaryService = cloudinaryService ?? CloudinaryService(),
        _supabaseService = supabaseService ?? SupabaseService();

  Future<bool> submitVerification(XFile selfieWithId) async {
    try {
      // Upload selfie with ID
      final imageUrl = await _cloudinaryService.uploadImage(selfieWithId);
      if (imageUrl == null) return false;

      // Get current user
      final user = await _supabaseService.getUserProfile(Supabase.instance.client.auth.currentUser!.id);

      // Get user profile
      final userProfile = await _supabaseService.getUserProfile(user.id);

      // Update verification status
      final updatedUser = userProfile.copyWith(
        selfieWithIdUrl: imageUrl,
        verificationStatus: VerificationStatus.pending,
        verificationRejectionReason: null,
      );

      await _supabaseService.updateUserProfile(updatedUser);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> approveVerification(String userId) async {
    try {
      final user = await _supabaseService.getUserProfile(userId);

      final updatedUser = user.copyWith(
        verificationStatus: VerificationStatus.approved,
        verifiedAt: DateTime.now(),
        verificationRejectionReason: null,
      );

      await _supabaseService.updateUserProfile(updatedUser);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectVerification(String userId, String reason) async {
    try {
      final user = await _supabaseService.getUserProfile(userId);

      final updatedUser = user.copyWith(
        verificationStatus: VerificationStatus.rejected,
        verificationRejectionReason: reason,
      );

      await _supabaseService.updateUserProfile(updatedUser);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<UserModel>> getVerifications(VerificationStatus status) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('verification_status', status.index)
          .order('created_at', ascending: false);

      return response.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
