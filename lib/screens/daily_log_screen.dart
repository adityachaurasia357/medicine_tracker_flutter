// lib/screens/daily_log_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicine_tracker/core/constants.dart';
import 'package:provider/provider.dart';
import '../state/medicine_provider.dart';
import 'all_logs_screen.dart';

class DailyLogScreen extends StatelessWidget {
  const DailyLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final provider = Provider.of<MedicineProvider>(context);
    final today = DateTime.now();
    
    // Get meds taken today
    final medsTakenToday = provider.medicines.where((m) => m.logs.any((l) => 
      l.year == today.year && l.month == today.month && l.day == today.day)).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        title: Text("Today's Logs", style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.calendar_month_rounded, color: colorScheme.primary),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllLogsScreen())),
            ),
          )
        ],
      ),
      body: medsTakenToday.isEmpty 
        ? _buildEmptyState(theme)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
                child: Text(
                  DateFormat('EEEE, MMMM d').format(today),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: colorScheme.onSurface.withOpacity(0.5), letterSpacing: 1.2),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  physics: const BouncingScrollPhysics(),
                  itemCount: medsTakenToday.length,
                  itemBuilder: (context, index) {
                    final med = medsTakenToday[index];
                    final todayLogs = med.logs.where((l) => l.day == today.day).toList();
                    final bool hasImage = med.displayImagePath != null && File(med.displayImagePath!).existsSync();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 15, offset: const Offset(0, 8))],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Thumbnail
                          Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              image: hasImage ? DecorationImage(image: FileImage(File(med.displayImagePath!)), fit: BoxFit.cover) : null,
                            ),
                            child: !hasImage ? Icon(Icons.medication_rounded, size: 30, color: colorScheme.primary) : null,
                          ),
                          const SizedBox(width: 16),
                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(med.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                                const SizedBox(height: 4),
                                Text("${med.timingRule.displayName} • Qty: ${med.quantity}", style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withOpacity(0.6))),
                                const SizedBox(height: 16),
                                // Time Badges
                                Wrap(
                                  spacing: 8, runSpacing: 8,
                                  children: todayLogs.map((log) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1B3320) : const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle_rounded, size: 14, color: Colors.green.shade600),
                                        const SizedBox(width: 6),
                                        Text(DateFormat('hh:mm a').format(log), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                                      ],
                                    ),
                                  )).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_rounded, size: 80, color: theme.colorScheme.onSurface.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text("No logs recorded today.", style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}