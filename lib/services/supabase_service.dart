import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/booking_model.dart';
import '../models/notification_model.dart';
import '../models/message_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient _client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    _client = Supabase.instance.client;
  }

  // Auth Methods
  Future<UserModel?> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      
      if (response.user != null) {
        // Create profile record
        await _client.from('profiles').insert({
          'id': response.user!.id,
          'email': email,  // Make sure to store email
          'full_name': fullName,
          'created_at': DateTime.now().toIso8601String(),
          'is_owner': false,
        });

        return UserModel(
          id: response.user!.id,
          email: email,
          fullName: fullName,
          createdAt: DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      print('SignUp Error: $e');  // Add logging
      rethrow;
    }
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        // Get the user's email from auth response
        final userEmail = response.user!.email;
        if (userEmail == null) {
          throw Exception('User email is null');
        }

        try {
          final userData = await getUserProfile(response.user!.id);
          // If profile doesn't exist, create it
          if (userData == null) {
            final newUser = UserModel(
              id: response.user!.id,
              email: userEmail,
              createdAt: DateTime.now(),
            );
            await _client.from('profiles').insert(newUser.toJson());
            return newUser;
          }
          return userData;
        } catch (e) {
          print('Profile Error: $e');  // Add logging
          // Create profile if it doesn't exist
          final newUser = UserModel(
            id: response.user!.id,
            email: userEmail,
            createdAt: DateTime.now(),
          );
          await _client.from('profiles').insert(newUser.toJson());
          return newUser;
        }
      }
      return null;
    } catch (e) {
      print('SignIn Error: $e');  // Add logging
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // User Methods
  Future<UserModel> getUserProfile(String userId) async {
    try {
      // Fetch user profile with all required columns
      final response = await _client
          .from('profiles')
          .select('''
            id, 
            email, 
            full_name, 
            phone_number, 
            avatar_url, 
            created_at, 
            is_owner, 
            address, 
            rating, 
            verification_status, 
            selfie_with_id_url, 
            verified_at, 
            verification_rejection_reason
          ''')
          .eq('id', userId)
          .single();
      
      // Get user email from auth metadata
      final user = await _client.auth.getUser();
      final userEmail = user.user?.email;
      
      if (userEmail == null) {
        throw Exception('User email is null');
      }

      // Add email to the response data
      response['email'] = userEmail;
      
      return UserModel.fromJson(response);
    } catch (e) {
      print('GetUserProfile Error: $e');
      if (e is PostgrestException && e.code == 'PGRST116') {
        throw Exception('User profile not found');
      }
      rethrow;
    }
  }

  Future<void> updateUserProfile(UserModel user) async {
    try {
      final dataToUpdate = user.toJson();
      // Remove email from update data as it's managed by auth
      dataToUpdate.remove('email');
      
      await _client
          .from('profiles')
          .update(dataToUpdate)
          .eq('id', user.id);
    } catch (e) {
      print('UpdateUserProfile Error: $e');  // Add logging
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  // Product Methods
  Future<List<ProductModel>> getProducts({
    String? category,
    String? search,
    bool? available,
  }) async {
    var query = _client.from('products').select();

    if (category != null) {
      query = query.eq('category', category);
    }
    if (search != null) {
      query = query.ilike('title', '%$search%');
    }
    if (available != null) {
      query = query.eq('is_available', available);
    }

    final response = await query;
    return (response as List)
        .map((item) => ProductModel.fromJson(item))
        .toList();
  }

  Future<ProductModel> createProduct(ProductModel product) async {
    final response = await _client
        .from('products')
        .insert(product.toJson())
        .select()
        .single();
    return ProductModel.fromJson(response);
  }

  Future<void> updateProduct(ProductModel product) async {
    await _client
        .from('products')
        .update(product.toJson())
        .eq('id', product.id);
  }

  // Booking Methods
  Future<List<Map<String, dynamic>>> getBookings({
    required String userId,
    bool asRenter = true,
  }) async {
    try {
      final String column = asRenter ? 'renter_id' : 'owner_id';
      final response = await _client
          .from('bookings')
          .select('''
            *,
            product:products(*),
            renter_profile:profiles!bookings_renter_id_fkey(*),
            owner_profile:profiles!bookings_owner_id_fkey(*)
          ''')
          .eq(column, userId)
          .order('created_at', ascending: false);
          
      return response;
    } catch (e) {
      print('Detailed booking error: $e'); // Add detailed logging
      throw Exception('Failed to get bookings: $e');
    }
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
    String? cancellationReason,
  }) async {
    try {
      final data = {
        'status': status,
        if (cancellationReason != null) 'cancellation_reason': cancellationReason,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client.from('bookings').update(data).eq('id', bookingId);
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  Future<void> addBookingReview({
    required String bookingId,
    required double rating,
    String? review,
  }) async {
    try {
      await _client.from('bookings').update({
        'rating': rating,
        'review': review,
        'reviewed_at': DateTime.now().toIso8601String(),
      }).eq('id', bookingId);
    } catch (e) {
      throw Exception('Failed to add booking review: $e');
    }
  }

  Future<Map<String, dynamic>> createBooking({
    required String productId,
    required String renterId,
    required DateTime startDate,
    required DateTime endDate,
    required double totalPrice,
  }) async {
    try {
      final response = await _client.from('bookings').insert({
        'product_id': productId,
        'renter_id': renterId,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'total_price': totalPrice,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      return response;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // Notifications
  Future<List<NotificationModel>> getNotifications({required String userId}) async {
    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return (response as List).map((e) => NotificationModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    String? bookingId,
  }) async {
    try {
      await _client.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type.toString().split('.').last,
        'booking_id': bookingId,
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      });
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  // Messages
  Future<List<MessageModel>> getMessages({required String bookingId}) async {
    try {
      final response = await _client
          .from('messages')
          .select()
          .eq('booking_id', bookingId)
          .order('created_at');

      return (response as List).map((e) => MessageModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }

  Future<void> sendMessage({
    required String bookingId,
    required String senderId,
    required String content,
  }) async {
    try {
      await _client.from('messages').insert({
        'booking_id': bookingId,
        'sender_id': senderId,
        'content': content,
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _client
          .from('messages')
          .update({'is_read': true})
          .eq('id', messageId);
    } catch (e) {
      throw Exception('Failed to mark message as read: $e');
    }
  }

  // Enhanced Booking Methods
  Future<void> acceptBooking(String bookingId) async {
    try {
      final booking = await _client
          .from('bookings')
          .select()
          .eq('id', bookingId)
          .single();

      await updateBookingStatus(
        bookingId: bookingId,
        status: 'confirmed',
      );

      // Notify the renter
      await createNotification(
        userId: booking['renter_id'],
        title: 'Booking Confirmed',
        message: 'Your booking has been confirmed by the owner.',
        type: NotificationType.bookingStatusUpdate,
        bookingId: bookingId,
      );
    } catch (e) {
      throw Exception('Failed to accept booking: $e');
    }
  }

  Future<void> rejectBooking(String bookingId, String reason) async {
    try {
      final booking = await _client
          .from('bookings')
          .select()
          .eq('id', bookingId)
          .single();

      await updateBookingStatus(
        bookingId: bookingId,
        status: 'declined',
        cancellationReason: reason,
      );

      // Notify the renter
      await createNotification(
        userId: booking['renter_id'],
        title: 'Booking Declined',
        message: 'Your booking has been declined by the owner: $reason',
        type: NotificationType.bookingStatusUpdate,
        bookingId: bookingId,
      );
    } catch (e) {
      throw Exception('Failed to reject booking: $e');
    }
  }
}
