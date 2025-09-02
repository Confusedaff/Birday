import 'package:bday/storage/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveBirthdayService {
  static const String _boxName = 'birthdays';
  static Box<Birthday>? _box;

  // Initialize Hive and open the box
  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(BirthdayAdapter().typeId)) {
      Hive.registerAdapter(BirthdayAdapter());
    }
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<Birthday>(_boxName);
    } else {
      _box = Hive.box<Birthday>(_boxName);
    }
  }
  // Expose the box safely
  static Box<Birthday> get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Hive box is not initialized. Call HiveBirthdayService.init() first');
    }
    return _box!;
  }

  // Add a new birthday
  static Future<void> addBirthday(Birthday birthday) async {
    await box.add(birthday);
  }

  // Get all birthdays
  static List<Birthday> getAllBirthdays() {
    return box.values.toList();
  }

  // Check if box has any birthdays
  static bool hasBirthdays() {
    return box.isNotEmpty; // ✅ no direct Hive.box call
  }

  // Update a birthday
  static Future<void> updateBirthday(int index, Birthday birthday) async {
    await box.putAt(index, birthday);
  }

  // Delete a birthday
  static Future<void> deleteBirthday(int index) async {
    await box.deleteAt(index);
  }

  // Get birthday by index
  static Birthday? getBirthday(int index) {
    return box.getAt(index);
  }

  // Find birthday by name
  static Birthday? findBirthdayByName(String name) {
    try {
      return box.values.firstWhere(
        (birthday) => birthday.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearAllBirthdays() async {
    await box.clear();
  }

  // Close the box
  static Future<void> close() async {
    await _box?.close();
    _box = null;
  }
}