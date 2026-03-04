import 'package:bday/storage/hive.dart';
import 'package:bday/services/logger_service.dart';
import 'package:bday/config/app_constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Service for managing birthday data persistence using Hive.
///
/// This is a singleton service that handles all database operations for birthdays.
/// It provides a clean abstraction over Hive with proper error handling and logging.
///
/// Key features:
/// - Lazy initialization of the Hive box
/// - Type-safe access to birthday data
/// - Error handling for database operations
/// - Logging of all operations for debugging
///
/// Usage:
/// ```dart
/// // Initialize once at app startup
/// await HiveBirthdayService.init();
///
/// // Use throughout the app
/// final birthdays = HiveBirthdayService.getAllBirthdays();
/// await HiveBirthdayService.addBirthday(newBirthday);
/// ```
class HiveBirthdayService {
  static const String _boxName = AppConstants.hiveBirthdayBoxName;
  static Box<Birthday>? _box;

  /// Initializes the Hive database and opens the birthday box.
  ///
  /// This method must be called once at application startup before any
  /// other HiveBirthdayService methods are used.
  ///
  /// It handles:
  /// - Registering the BirthdayAdapter if not already registered
  /// - Opening or retrieving the birthday box
  /// - Logging initialization status
  ///
  /// Throws:
  ///   - [Exception] if initialization fails (e.g., corrupted database)
  ///
  /// Safe to call multiple times - subsequent calls are no-ops if box is
  /// already open.
  static Future<void> init() async {
    try {
      if (!Hive.isAdapterRegistered(BirthdayAdapter().typeId)) {
        Hive.registerAdapter(BirthdayAdapter());
        AppLogger.debug('Registered BirthdayAdapter');
      }

      if (!Hive.isBoxOpen(_boxName)) {
        _box = await Hive.openBox<Birthday>(_boxName);
        AppLogger.info('Opened Hive box: $_boxName');
      } else {
        _box = Hive.box<Birthday>(_boxName);
        AppLogger.debug('Retrieved existing Hive box: $_boxName');
      }
    } catch (e) {
      AppLogger.error(
        'Failed to initialize Hive database',
        error: e,
      );
      rethrow;
    }
  }

  /// Provides safe access to the Hive birthday box.
  ///
  /// Returns the currently open box, or throws an exception if the box
  /// hasn't been initialized yet.
  ///
  /// Throws:
  ///   - [Exception] if [init()] hasn't been called or the box is closed
  ///
  /// Returns: The open [Box<Birthday>] instance
  static Box<Birthday> get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception(
        'Hive box is not initialized. Call HiveBirthdayService.init() first',
      );
    }
    return _box!;
  }

  /// Adds a new birthday to the database.
  ///
  /// Parameters:
  ///   - birthday: The [Birthday] object to add
  ///
  /// Throws:
  ///   - [Exception] if the database is not initialized
  ///   - Hive-specific exceptions for database errors
  ///
  /// Example:
  /// ```dart
  /// final newBirthday = Birthday(
  ///   name: 'John Doe',
  ///   birthDate: DateTime(1990, 3, 15),
  /// );
  /// await HiveBirthdayService.addBirthday(newBirthday);
  /// ```
  static Future<void> addBirthday(Birthday birthday) async {
    try {
      await box.add(birthday);
      AppLogger.info('Added birthday: ${birthday.name}');
    } catch (e) {
      AppLogger.error(
        'Failed to add birthday: ${birthday.name}',
        error: e,
      );
      rethrow;
    }
  }

  /// Retrieves all birthdays from the database.
  ///
  /// Returns an empty list if no birthdays exist.
  ///
  /// Returns: A [List<Birthday>] of all stored birthdays
  ///
  /// Note: This creates a copy of the list, so modifications don't affect
  /// the underlying database directly.
  static List<Birthday> getAllBirthdays() {
    try {
      return box.values.toList();
    } catch (e) {
      AppLogger.error(
        'Failed to retrieve all birthdays',
        error: e,
      );
      return [];
    }
  }

  /// Checks if there are any birthdays in the database.
  ///
  /// Returns: `true` if at least one birthday exists, `false` otherwise
  static bool hasBirthdays() {
    try {
      return box.isNotEmpty;
    } catch (e) {
      AppLogger.error(
        'Failed to check if birthdays exist',
        error: e,
      );
      return false;
    }
  }

  /// Updates an existing birthday in the database.
  ///
  /// Replaces the birthday at the given index with the new birthday object.
  ///
  /// Parameters:
  ///   - index: The index of the birthday to update
  ///   - birthday: The updated [Birthday] object
  ///
  /// Throws:
  ///   - [RangeError] if index is out of bounds
  ///   - Hive-specific exceptions for database errors
  ///
  /// Example:
  /// ```dart
  /// final updated = birthday.copyWith(age: age + 1);
  /// await HiveBirthdayService.updateBirthday(0, updated);
  /// ```
  static Future<void> updateBirthday(int index, Birthday birthday) async {
    try {
      await box.putAt(index, birthday);
      AppLogger.info('Updated birthday at index $index: ${birthday.name}');
    } catch (e) {
      AppLogger.error(
        'Failed to update birthday at index $index',
        error: e,
      );
      rethrow;
    }
  }

  /// Deletes a birthday from the database.
  ///
  /// Parameters:
  ///   - index: The index of the birthday to delete
  ///
  /// Throws:
  ///   - [RangeError] if index is out of bounds
  ///   - Hive-specific exceptions for database errors
  static Future<void> deleteBirthday(int index) async {
    try {
      final birthday = box.getAt(index);
      await box.deleteAt(index);
      AppLogger.info('Deleted birthday: ${birthday?.name ?? 'unknown'}');
    } catch (e) {
      AppLogger.error(
        'Failed to delete birthday at index $index',
        error: e,
      );
      rethrow;
    }
  }

  /// Retrieves a birthday by its index.
  ///
  /// Parameters:
  ///   - index: The index of the birthday to retrieve
  ///
  /// Returns: The [Birthday] at the given index, or `null` if index is
  /// out of bounds
  static Birthday? getBirthday(int index) {
    try {
      return box.getAt(index);
    } catch (e) {
      AppLogger.error(
        'Failed to retrieve birthday at index $index',
        error: e,
      );
      return null;
    }
  }

  /// Finds a birthday by name (case-insensitive).
  ///
  /// Searches through all birthdays and returns the first one matching
  /// the given name (comparison is case-insensitive).
  ///
  /// Parameters:
  ///   - name: The name to search for
  ///
  /// Returns: The matching [Birthday], or `null` if not found
  ///
  /// Example:
  /// ```dart
  /// final birthday = HiveBirthdayService.findBirthdayByName('John');
  /// ```
  static Birthday? findBirthdayByName(String name) {
    try {
      return box.values.firstWhere(
        (birthday) => birthday.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      AppLogger.debug('Birthday not found: $name');
      return null;
    }
  }

  /// Deletes all birthdays from the database.
  ///
  /// Warning: This operation is irreversible. Use with caution.
  ///
  /// Throws:
  ///   - Hive-specific exceptions for database errors
  static Future<void> clearAllBirthdays() async {
    try {
      final count = box.length;
      await box.clear();
      AppLogger.warning('Cleared all $count birthdays from database');
    } catch (e) {
      AppLogger.error(
        'Failed to clear all birthdays',
        error: e,
      );
      rethrow;
    }
  }

  /// Closes the Hive box and releases database resources.
  ///
  /// Should be called when the app closes or when you're done with
  /// the database. After calling this, [init()] must be called again
  /// before using the service.
  static Future<void> close() async {
    try {
      await _box?.close();
      _box = null;
      AppLogger.debug('Closed Hive box: $_boxName');
    } catch (e) {
      AppLogger.error(
        'Failed to close Hive box',
        error: e,
      );
    }
  }
}