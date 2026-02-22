// lib/screens/all_logs_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../state/medicine_provider.dart';

class AllLogsScreen extends StatelessWidget {
  const AllLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final provider = Provider.of<MedicineProvider>(context);

    // 1. Group logs by Date string (e.g., "Feb 22, 2026")
    Map<String, List<Map<String, dynamic>>> groupedLogs = {};
    
    for (var med in provider.medicines) {
      for (var log in med.logs) {
        // Create a date key (stripping out the time)
        String dateKey = DateFormat('MMMM d, yyyy').format(log);
        if (!groupedLogs.containsKey(dateKey)) {
          groupedLogs[dateKey] = [];
        }
        groupedLogs[dateKey]!.add({
          'name': med.name,
          'time': log,
          'imagePath': med.displayImagePath,
        });
      }
    }

    // 2. Sort the dates (keys) from newest to oldest
    List<String> sortedDates = groupedLogs.keys.toList()
      ..sort((a, b) => DateFormat('MMMM d, yyyy').parse(b).compareTo(DateFormat('MMMM d, yyyy').parse(a)));

    // 3. Sort the entries within each date from newest to oldest time
    for (var date in sortedDates) {
      groupedLogs[date]!.sort((a, b) => b['time'].compareTo(a['time']));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        title: Text("Complete History", style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
      ),
      body: sortedDates.isEmpty 
        ? _buildEmptyState(theme)
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              String date = sortedDates[index];
              List<Map<String, dynamic>> dayLogs = groupedLogs[date]!;

              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // The Date Header
                    Row(
                      children: [
                        Container(width: 4, height: 20, decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(4))),
                        const SizedBox(width: 12),
                        Text(date, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: colorScheme.onSurface.withOpacity(0.6), letterSpacing: 1)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // The Card containing that day's logs
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 15, offset: const Offset(0, 8))],
                      ),
                      child: Column(
                        children: List.generate(dayLogs.length, (i) {
                          final log = dayLogs[i];
                          final DateTime time = log['time'];
                          final String? imgPath = log['imagePath'];
                          final bool hasImage = imgPath != null && File(imgPath).existsSync();

                          return Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                leading: Container(
                                  width: 45, height: 45,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    image: hasImage ? DecorationImage(image: FileImage(File(imgPath)), fit: BoxFit.cover) : null,
                                  ),
                                  child: !hasImage ? Icon(Icons.medication_rounded, color: colorScheme.primary) : null,
                                ),
                                title: Text(log['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface)),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: colorScheme.onSurface.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                                  child: Text(DateFormat('hh:mm a').format(time), style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface.withOpacity(0.8), fontSize: 13)),
                                ),
                              ),
                              // Add a subtle divider between items, except the last one
                              if (i < dayLogs.length - 1)
                                Divider(height: 1, indent: 80, endIndent: 20, color: theme.dividerColor.withOpacity(0.1)),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_rounded, size: 80, color: theme.colorScheme.onSurface.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text("No history recorded yet.", style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}