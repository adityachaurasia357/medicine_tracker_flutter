// lib/widgets/medicine_card.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../core/constants.dart';
import '../screens/add_medicine_screen.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final bool isTaken;
  final VoidCallback onTap;

  const MedicineCard({
    super.key,
    required this.medicine,
    required this.isTaken,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isTaken ? const Color(0xFFE8F5E9) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isTaken)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          onLongPress: () {
            Feedback.forLongPress(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => AddMedicineScreen(medicineToEdit: medicine),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // --- Premium Image Slot ---
                _buildMedicineThumbnail(context),
                
                const SizedBox(width: 16),
                
                // --- Medicine Info ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(
                              medicine.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: isTaken ? TextDecoration.lineThrough : null,
                                color: isTaken ? Colors.green.shade700 : Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "x${medicine.quantity}",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isTaken ? Colors.green.shade600 : Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${medicine.timingRule.displayName} • ${medicine.mealTime.displayName}",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isTaken ? Colors.green.shade600 : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.alarm_on_rounded,
                            size: 14,
                            color: isTaken ? Colors.green.shade400 : Colors.grey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${medicine.notificationHour.toString().padLeft(2, '0')}:${medicine.notificationMinute.toString().padLeft(2, '0')}",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isTaken ? Colors.green.shade400 : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // --- Interactive Checkmark ---
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isTaken ? Colors.green.shade100 : const Color(0xFFF0F4FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isTaken ? Icons.done_all_rounded : Icons.add_task_rounded,
                    size: 24,
                    color: isTaken ? Colors.green.shade700 : Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineThumbnail(BuildContext context) {
    // Check if image exists and is valid
    final bool hasImage = medicine.displayImagePath != null && 
                         File(medicine.displayImagePath!).existsSync();

    return GestureDetector(
      onTap: hasImage ? () => _showFullScreenImage(context) : null,
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          color: isTaken ? Colors.green.shade100 : Colors.blueAccent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          image: hasImage 
              ? DecorationImage(
                  image: FileImage(File(medicine.displayImagePath!)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: !hasImage 
            ? Icon(
                Icons.medication_rounded,
                size: 30,
                color: isTaken ? Colors.green.shade400 : Colors.blueAccent.withOpacity(0.5),
              )
            : null,
      ),
    );
  }

  // A quick high-end preview so your dad can see the full pill photo
  void _showFullScreenImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.file(File(medicine.displayImagePath!)),
            ),
            const SizedBox(height: 12),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}