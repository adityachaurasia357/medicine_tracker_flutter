// lib/screens/inventory_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:medicine_tracker/core/toast_service.dart';
import 'package:provider/provider.dart';
import '../state/medicine_provider.dart';
import '../core/constants.dart';
import 'add_medicine_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Medication Inventory",
          style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<MedicineProvider>(
        builder: (context, provider, child) {
          final allMeds = provider.medicines;
          
          // --- Filter Logic ---
          final filteredMeds = allMeds.where((med) {
            return med.name.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          if (allMeds.isEmpty) {
            return _buildEmptyState(context, "Your inventory is empty", Icons.inventory_2_outlined);
          }

          return Column(
            children: [
              // --- Premium Search Bar ---
              _buildSearchBar(context),

              Expanded(
                child: filteredMeds.isEmpty 
                  ? _buildEmptyState(context, "No medicines match '$_searchQuery'", Icons.search_off_rounded)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredMeds.length,
                      itemBuilder: (context, index) {
                        final med = filteredMeds[index];
                        final bool hasImage = med.displayImagePath != null && File(med.displayImagePath!).existsSync();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Theme(
                              data: theme.copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                expansionAnimationStyle: AnimationStyle(
                                  curve: Curves.easeInOutCubic,
                                  duration: const Duration(milliseconds: 400),
                                ),
                                tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                iconColor: colorScheme.primary,
                                collapsedIconColor: colorScheme.onSurface.withOpacity(0.5),
                                leading: Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(14),
                                    image: hasImage 
                                        ? DecorationImage(
                                            image: FileImage(File(med.displayImagePath!)),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: !hasImage 
                                      ? Icon(Icons.medication_rounded, color: colorScheme.primary)
                                      : null,
                                ),
                                title: Text(
                                  med.name,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                                ),
                                subtitle: Text(
                                  "Quantity: ${med.quantity}",
                                  style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w500),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Divider(color: theme.dividerColor.withOpacity(0.1), height: 1),
                                        const SizedBox(height: 16),
                                        
                                        if (med.images.isNotEmpty) ...[
                                          Text(
                                            "PHOTO GALLERY",
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: colorScheme.onSurface.withOpacity(0.4), letterSpacing: 1),
                                          ),
                                          const SizedBox(height: 10),
                                          SizedBox(
                                            height: 80,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              physics: const BouncingScrollPhysics(),
                                              itemCount: med.images.length,
                                              itemBuilder: (ctx, i) => Container(
                                                width: 80,
                                                margin: const EdgeInsets.only(right: 10),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(12),
                                                  image: DecorationImage(
                                                    image: FileImage(File(med.images[i])),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                        ],

                                        _buildInfoRow(context, Icons.schedule, "Schedule", med.timingRule.displayName),
                                        const SizedBox(height: 12),
                                        _buildInfoRow(context, Icons.restaurant, "Condition", med.mealTime.displayName),
                                        const SizedBox(height: 12),
                                        _buildInfoRow(context, Icons.alarm, "Daily Alarm", 
                                          "${med.notificationHour.toString().padLeft(2, '0')}:${med.notificationMinute.toString().padLeft(2, '0')}"),
                                        
                                        const SizedBox(height: 24),
                                        
                                        Row(
                                          children: [
                                            Expanded(
                                              child: SizedBox(
                                                height: 48,
                                                child: ElevatedButton.icon(
                                                  onPressed: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (_) => AddMedicineScreen(medicineToEdit: med)),
                                                  ),
                                                  icon: const Icon(Icons.edit_note_rounded, size: 20),
                                                  label: const Text("Edit", style: TextStyle(fontWeight: FontWeight.bold)),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: colorScheme.primary,
                                                    foregroundColor: Colors.white,
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: SizedBox(
                                                height: 48,
                                                child: OutlinedButton.icon(
                                                  onPressed: () => _confirmDelete(context, provider, med),
                                                  icon: const Icon(Icons.delete_sweep_outlined, size: 20),
                                                  label: const Text("Delete", style: TextStyle(fontWeight: FontWeight.bold)),
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor: Colors.redAccent,
                                                    side: BorderSide(color: Colors.redAccent.withOpacity(0.1)),
                                                    backgroundColor: Colors.redAccent.withOpacity(0.05),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: "Search your medicines...",
            hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
            prefixIcon: Icon(Icons.search_rounded, color: colorScheme.primary.withOpacity(0.5)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16, 
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), 
              fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.onSurface.withOpacity(0.3)),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 14)),
        const Spacer(),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colorScheme.onSurface)),
      ],
    );
  }

  void _confirmDelete(BuildContext context, MedicineProvider provider, var med) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Delete Medicine?", style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
        content: Text("This will permanently remove ${med.name} from your records.", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("CANCEL", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              provider.deleteMedicine(med.id);
              Navigator.pop(ctx);
              ToastService.show(context, "${med.name} removed", isError: true);
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}