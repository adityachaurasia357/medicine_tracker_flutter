import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'add_medicine_screen.dart';
import 'inventory_screen.dart';
import 'settings_screen.dart';

class BaseNavScreen extends StatefulWidget {
  const BaseNavScreen({super.key});

  @override
  State<BaseNavScreen> createState() => _BaseNavScreenState();
}

class _BaseNavScreenState extends State<BaseNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const InventoryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // 1. Grab the current theme data
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      
      floatingActionButton: AnimatedScale(
        scale: _currentIndex != 2 ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        child: FloatingActionButton.large(
          elevation: 4,
          // Use primary color from theme instead of hardcoded blue
          backgroundColor: colorScheme.primary, 
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => const AddMedicineScreen(),
              ),
            );
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Icon(Icons.add_rounded, size: 36, color: colorScheme.onPrimary),
        ),
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              // Adjust shadow opacity based on theme for better depth
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            // Uses primary color with low opacity for the pill indicator
            indicatorColor: colorScheme.primary.withOpacity(0.1),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return TextStyle(
                  fontSize: 13, 
                  fontWeight: FontWeight.bold, 
                  color: colorScheme.primary // Matches theme primary
                );
              }
              return TextStyle(
                fontSize: 12, 
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600
              );
            }),
          ),
          child: NavigationBar(
            height: 75,
            elevation: 0,
            // Uses surface color (White in light, Charcoal in dark)
            backgroundColor: colorScheme.surface, 
            selectedIndex: _currentIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: [
              _buildNavDestination(
                context,
                icon: Icons.today_outlined,
                activeIcon: Icons.today_rounded,
                label: 'Today',
              ),
              _buildNavDestination(
                context,
                icon: Icons.inventory_2_outlined,
                activeIcon: Icons.inventory_2_rounded,
                label: 'Inventory',
              ),
              _buildNavDestination(
                context,
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings_rounded,
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }

  NavigationDestination _buildNavDestination(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return NavigationDestination(
      icon: Icon(
        icon, 
        size: 26, 
        color: isDark ? Colors.grey.shade500 : Colors.grey.shade600
      ),
      selectedIcon: Icon(activeIcon, size: 28, color: colorScheme.primary),
      label: label,
    );
  }
}