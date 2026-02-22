// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/medicine_provider.dart';
import '../widgets/medicine_card.dart';
import '../core/constants.dart';
import 'daily_log_screen.dart'; // IMPORTANT: Added this import

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<MedicineProvider>(
        builder: (context, provider, child) {
          final meds = provider.medicines;
          final takenMeds = meds.where((m) => m.isTakenToday).length;
          final totalMeds = meds.length;
          final double progress = totalMeds == 0 ? 0 : takenMeds / totalMeds;

          if (meds.isEmpty) {
            return _buildFixedEmptyLayout(context);
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Today's Schedule",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // FIXED: Added the GestureDetector right here!
              SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DailyLogScreen()),
                    );
                  },
                  child: _buildProgressCard(context, takenMeds, totalMeds, progress),
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final meal = MealTime.values[index];
                  final mealMeds = meds
                      .where((m) => m.mealTime == meal)
                      .toList();
                  if (mealMeds.isEmpty) return const SizedBox.shrink();

                  return _buildMealSection(context, meal, mealMeds, provider);
                }, childCount: MealTime.values.length),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFixedEmptyLayout(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getGreeting(),
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Today's Schedule",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const Spacer(flex: 4),
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.2 : 0.03),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.medication_liquid_outlined,
                    size: 70,
                    color: colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "No medicines yet",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Your daily schedule will appear here.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15, 
                    color: colorScheme.onSurface.withOpacity(0.5)
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, int taken, int total, double progress) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [const Color(0xFF1E88E5), const Color(0xFF1565C0)] 
            : [const Color(0xFF448AFF), const Color(0xFF2979FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(isDark ? 0.3 : 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Your Progress",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "$taken/$total Done",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            progress == 1.0
                ? "All caught up! Great job."
                : "Stay healthy! ${total - taken} more to go today.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSection(
    BuildContext context,
    MealTime meal,
    List mealMeds,
    MedicineProvider provider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 30, 24, 12),
          child: Row(
            children: [
              Text(
                meal.displayName.toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.primary.withOpacity(0.8),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Divider(
                  color: theme.dividerColor.withOpacity(0.1), 
                  thickness: 1
                ),
              ),
            ],
          ),
        ),
        ...mealMeds.map(
          (med) => MedicineCard(
            medicine: med,
            isTaken: med.isTakenToday,
            onTap: () => provider.markAsTaken(med.id),
          ),
        ),
      ],
    );
  }
}