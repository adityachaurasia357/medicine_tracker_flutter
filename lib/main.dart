// lib/main.dart
import 'package:flutter/material.dart';
import 'package:medicine_tracker/state/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'core/theme.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'state/medicine_provider.dart';
import 'screens/base_nav_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize core services
  await StorageService.init();
  await NotificationService.init();

  // 2. Request basic Notification permissions only
  // This is required for Android 13+ to show any notification at all
  await [Permission.notification].request();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MedicineProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MedicineTrackerApp(),
    ),
  );
} // ... rest of MedicineTrackerApp class remains the same

class MedicineTrackerApp extends StatelessWidget {
  const MedicineTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    // MultiProvider injects our state into the app so any screen can access the medicine list
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          // As soon as the provider is created, it loads the saved medicines from the database
          create: (_) => MedicineProvider()..loadMedicines(),
        ),
      ],
      child: MaterialApp(
        title: 'Medicine Tracker',
        debugShowCheckedModeBanner:
            false, // Removes the red debug banner on the top right
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeProvider.themeMode, // Applies our massive, high-contrast theme
        home: const BaseNavScreen(), // Routes to our bottom navigation bar
      ),
    );
  }
}
