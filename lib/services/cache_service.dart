import 'dart:convert';

import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/booking_model.dart';
import '../models/chat_message_model.dart';
import '../models/product_model.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static Database? _db;
  static const String dbName = 'rusht_cache.db';
  static const String messageTable = 'messages';
  static const String bookingTable = 'bookings';
  static const String productTable = 'products';
  static const String pendingActionsTable = 'pending_actions';

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $messageTable (
            id TEXT PRIMARY KEY,
            booking_id TEXT,
            sender_id TEXT,
            content TEXT,
            created_at TEXT,
            status TEXT,
            error TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE $bookingTable (
            id TEXT PRIMARY KEY,
            product_id TEXT,
            renter_id TEXT,
            start_date TEXT,
            end_date TEXT,
            total_price REAL,
            status TEXT,
            cached_at TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE $productTable (
            id TEXT PRIMARY KEY,
            title TEXT,
            description TEXT,
            price REAL,
            owner_id TEXT,
            category TEXT,
            images TEXT,
            cached_at TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE $pendingActionsTable (
            id TEXT PRIMARY KEY,
            action TEXT,
            data TEXT,
            created_at TEXT,
            retries INTEGER
          )
        ''');
      },
    );
  }

  // Message Caching
  Future<void> cacheMessages(List<ChatMessageModel> messages, String bookingId) async {
    final db = await database;
    final batch = db.batch();

    for (final message in messages) {
      batch.insert(
        messageTable,
        message.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<ChatMessageModel>> getCachedMessages(String bookingId) async {
    final db = await database;
    final results = await db.query(
      messageTable,
      where: 'booking_id = ?',
      whereArgs: [bookingId],
      orderBy: 'created_at DESC',
    );

    return results.map((json) => ChatMessageModel.fromJson(json)).toList();
  }

  // Booking Caching
  Future<void> cacheBookings(List<BookingModel> bookings) async {
    final db = await database;
    final batch = db.batch();

    for (final booking in bookings) {
      final data = booking.toJson();
      data['cached_at'] = DateTime.now().toIso8601String();
      batch.insert(
        bookingTable,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<BookingModel>> getCachedBookings() async {
    final db = await database;
    final results = await db.query(
      bookingTable,
      orderBy: 'cached_at DESC',
    );

    return results.map((json) => BookingModel.fromJson(json)).toList();
  }

  // Product Caching
  Future<void> cacheProducts(List<ProductModel> products) async {
    final db = await database;
    final batch = db.batch();

    for (final product in products) {
      final data = product.toJson();
      data['cached_at'] = DateTime.now().toIso8601String();
      data['images'] = jsonEncode(product.images);
      batch.insert(
        productTable,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<ProductModel>> getCachedProducts() async {
    final db = await database;
    final results = await db.query(
      productTable,
      orderBy: 'cached_at DESC',
    );

    return results.map((json) {
      json['images'] = jsonDecode(json['images'] as String);
      return ProductModel.fromJson(json);
    }).toList();
  }

  // Pending Actions
  Future<void> addPendingAction(String action, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(
      pendingActionsTable,
      {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'action': action,
        'data': jsonEncode(data),
        'created_at': DateTime.now().toIso8601String(),
        'retries': 0,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getPendingActions() async {
    final db = await database;
    final results = await db.query(
      pendingActionsTable,
      orderBy: 'created_at ASC',
    );

    return results.map((json) {
      json['data'] = jsonDecode(json['data'] as String);
      return json;
    }).toList();
  }

  Future<void> removePendingAction(String id) async {
    final db = await database;
    await db.delete(
      pendingActionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> incrementRetryCount(String id) async {
    final db = await database;
    await db.rawUpdate('''
      UPDATE $pendingActionsTable
      SET retries = retries + 1
      WHERE id = ?
    ''', [id]);
  }

  // Preferences
  Future<void> savePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else {
      await prefs.setString(key, jsonEncode(value));
    }
  }

  Future<T?> getPreference<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key) as T?;
  }

  Future<void> removePreference(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // Clear Cache
  Future<void> clearCache() async {
    final db = await database;
    await db.delete(messageTable);
    await db.delete(bookingTable);
    await db.delete(productTable);
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
