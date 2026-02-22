// lib/state/medicine_provider.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // Helpful for generating unique IDs
import '../models/medicine.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../core/constants.dart';

class MedicineProvider with ChangeNotifier {
  List<Medicine> _medicines = [];
  final _uuid = const Uuid();

  List<Medicine> get medicines => _medicines;

  // Load medicines from Hive database
  Future<void> loadMedicines() async {
    _medicines = StorageService.getAllMedicines();
    notifyListeners();
  }

  // Improved Add Medicine: Generates the ID and schedules the alarm automatically
  Future<void> addMedicine(
    String name,
    String quantity, // Add this
    TimingRule rule,
    MealTime meal,
    int hour,
    int minute,
  ) async {
    final newMedicine = Medicine(
      id: const Uuid().v4(),
      name: name,
      quantity: quantity, // Use it here
      timingRule: rule,
      mealTime: meal,
      notificationHour: hour,
      notificationMinute: minute,
    );

    _medicines.add(newMedicine);
    await StorageService.saveMedicine(newMedicine);
    await NotificationService.scheduleDailyReminder(newMedicine);
    notifyListeners();
  }

  // Update an existing medicine (Edit Mode)
  Future<void> updateMedicine(Medicine updatedMed) async {
    final index = _medicines.indexWhere((m) => m.id == updatedMed.id);
    if (index != -1) {
      _medicines[index] = updatedMed;

      // 1. Save to local storage
      await StorageService.saveMedicine(updatedMed);

      // 2. Refresh the alarm (Cancel old, set new)
      await NotificationService.cancelReminder(updatedMed.id);
      await NotificationService.scheduleDailyReminder(updatedMed);

      notifyListeners();
    }
  }

  // Mark as taken (updates only the date, keeps alarm settings)
  Future<void> markAsTaken(String id) async {
    final index = _medicines.indexWhere((m) => m.id == id);
    if (index != -1) {
      final med = _medicines[index];

      // If it is already taken today, exit the function immediately. Do nothing.
      if (med.isTakenToday) {
        return;
      }

      // If it hasn't been taken today, record the exact time.
      final now = DateTime.now();
      med.logs.add(now);
      med.lastTakenDate = now;

      await StorageService.saveMedicine(med);
      notifyListeners();
    }
  }

  // Remove medicine entirely
  Future<void> deleteMedicine(String id) async {
    _medicines.removeWhere((med) => med.id == id);
    await StorageService.deleteMedicine(id);
    await NotificationService.cancelReminder(id);
    notifyListeners();
  }

  bool exists(String name, {String? excludeId}) {
    return _medicines.any(
      (m) =>
          m.name.toLowerCase().trim() == name.toLowerCase().trim() &&
          m.id != excludeId,
    );
  }

  Future<void> addMedicineFull(Medicine medicine) async {
    _medicines.add(medicine);

    // Save to Hive/Local Storage
    await StorageService.saveMedicine(medicine);

    // Schedule the notification for this new medicine
    await NotificationService.scheduleDailyReminder(medicine);

    notifyListeners();
  }
}
