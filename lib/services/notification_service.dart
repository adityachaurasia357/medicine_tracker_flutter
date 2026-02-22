// lib/services/notification_service.dart

import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart'
    as tz; // Using latest_all for better coverage
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

import '../models/medicine.dart';
import '../core/constants.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static late tz.Location _deviceLocation;

  // -------------------- INIT --------------------

  static Future<void> init() async {
    // 1. Initialize the timezone database
    tz.initializeTimeZones();

    try {
      // 2. Get device timezone with a 2-second timeout to prevent "Logo Freeze"
      // Latest flutter_timezone returns a string name directly from getLocalTimezone()
      final timezoneInfo = await FlutterTimezone.getLocalTimezone().timeout(
        const Duration(seconds: 2),
      );

      final String timeZoneName = timezoneInfo.identifier;
      _deviceLocation = tz.getLocation(timeZoneName);
    } catch (e) {
      // Fallback if it takes too long or fails
      debugPrint("Timezone detection failed or timed out: $e");
      _deviceLocation = tz.getLocation('Asia/Kolkata');
    }

    // Set the library's local pointer
    tz.setLocalLocation(_deviceLocation);

    // 3. Android settings (uses your app icon)
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 4. iOS settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // FIX: initializationSettings is the required named parameter
    await _notificationsPlugin.initialize(
      settings: initSettings,

      onDidReceiveNotificationResponse:
          (NotificationResponse response) async {},
    );

    // Android 13+ runtime permission check
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  // -------------------- DAILY REMINDER --------------------

  static Future<void> scheduleDailyReminder(Medicine medicine) async {
    // Ensure positive ID for Android
    final int notificationId = medicine.id.hashCode.abs() % 2147483647;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'medicine_channel_id',
          'Medicine Reminders',
          channelDescription: 'Daily reminders to take medication',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          // Helps show alarm over lockscreen
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    // Precise local time calculation using the stored Location object
    final tz.TZDateTime now = tz.TZDateTime.now(_deviceLocation);

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      _deviceLocation,
      now.year,
      now.month,
      now.day,
      medicine.notificationHour,
      medicine.notificationMinute,
    );

    // If time already passed today → schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      id: notificationId,
      title: 'Time for your medicine',
      body:
          'Take ${medicine.name} (${medicine.timingRule.displayName} ${medicine.mealTime.displayName})',
      scheduledDate: scheduledDate,
      notificationDetails: platformDetails,
      // Most reliable mode for Android health apps
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );

    debugPrint("Alarm successfully set for: ${scheduledDate.toString()}");
  }

  // -------------------- CANCEL REMINDER --------------------

  static Future<void> cancelReminder(String medicineId) async {
    final int notificationId = medicineId.hashCode.abs() % 2147483647;
    await _notificationsPlugin.cancel(id: notificationId);
  }
  
}
