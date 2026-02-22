// lib/services/storage_service.dart

import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/medicine.dart';
import '../core/constants.dart';

class StorageService {
  static const String _boxName = 'medicineBox';
  static late Box<String> _box;

  // Initialize Hive and open the storage box
  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  // Get all saved medicines
  static List<Medicine> getAllMedicines() {
    final List<Medicine> medicines = [];
    for (var key in _box.keys) {
      final String? jsonString = _box.get(key);
      if (jsonString != null) {
        medicines.add(_fromJson(jsonString));
      }
    }
    return medicines;
  }

  // Save or Update a medicine
  static Future<void> saveMedicine(Medicine medicine) async {
    final String jsonString = _toJson(medicine);
    await _box.put(medicine.id, jsonString);
  }

  // Delete a medicine
  static Future<void> deleteMedicine(String id) async {
    await _box.delete(id);
  }

  // --- Helpers to convert between Medicine and JSON strings ---

  static String _toJson(Medicine med) {
    return jsonEncode({
      'id': med.id,
      'name': med.name,
      'quantity': med.quantity,
      'mealTime': med.mealTime.index,
      'timingRule': med.timingRule.index,
      'notificationHour': med.notificationHour,
      'notificationMinute': med.notificationHour,
      'lastTakenDate': med.lastTakenDate?.toIso8601String(),
      'images': med.images,
      'displayImagePath': med.displayImagePath,
      'logs': med.logs.map((log) => log.toIso8601String()).toList(),
    });
  }

  static Medicine _fromJson(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    return Medicine(
      id: data['id'],
      name: data['name'],
      quantity: data['quantity'] ?? "1",
      mealTime: MealTime.values[data['mealTime']],
      timingRule: TimingRule.values[data['timingRule']],
      notificationHour: data['notificationHour'],
      notificationMinute: data['notificationMinute'],
      lastTakenDate: data['lastTakenDate'] != null
          ? DateTime.parse(data['lastTakenDate'])
          : null,
      // NEW: Parse image list and display path with safety fallbacks
      images: List<String>.from(data['images'] ?? []),
      displayImagePath: data['displayImagePath'],
    );
  }
}
