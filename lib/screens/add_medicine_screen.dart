import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/medicine.dart';
import '../state/medicine_provider.dart';
import '../core/constants.dart';
import '../core/toast_service.dart';

class AddMedicineScreen extends StatefulWidget {
  final Medicine? medicineToEdit;
  const AddMedicineScreen({super.key, this.medicineToEdit});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TimingRule _selectedRule;
  late MealTime _selectedMeal;
  late TimeOfDay _selectedTime;

  // --- Image State ---
  List<String> _images = [];
  String? _displayImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medicineToEdit?.name ?? "");
    _quantityController = TextEditingController(text: widget.medicineToEdit?.quantity ?? "1");
    
    _images = List.from(widget.medicineToEdit?.images ?? []);
    _displayImagePath = widget.medicineToEdit?.displayImagePath;

    _nameController.addListener(_updateUI);
    _quantityController.addListener(_updateUI);

    _selectedRule = widget.medicineToEdit?.timingRule ?? TimingRule.afterMeal;
    _selectedMeal = widget.medicineToEdit?.mealTime ?? MealTime.breakfast;
    _selectedTime = widget.medicineToEdit != null
        ? TimeOfDay(
            hour: widget.medicineToEdit!.notificationHour,
            minute: widget.medicineToEdit!.notificationMinute,
          )
        : const TimeOfDay(hour: 8, minute: 0);
  }

  void _updateUI() => setState(() {});

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // --- Image Picking Logic ---
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 50, 
    );

    if (image != null) {
      setState(() {
        _images.add(image.path);
        _displayImagePath ??= image.path;
      });
    }
  }

  void _showImageSourceSheet() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text("Add Photo", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: "Camera",
                  color: Colors.blueAccent,
                  onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
                ),
                _buildSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: "Gallery",
                  color: Colors.orangeAccent,
                  onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showImageOptions(String path, int index) {
    final theme = Theme.of(context);
    Feedback.forLongPress(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, 
      builder: (context) => Container(
        padding: EdgeInsets.only(
          left: 24, 
          right: 24, 
          top: 24, 
          bottom: MediaQuery.of(context).padding.bottom + 20, 
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              ),
              title: const Text("Delete Photo", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _confirmPhotoDeletion(path, index);
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("CANCEL", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmPhotoDeletion(String path, int index) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Remove Photo?", style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        content: Text("This photo will be removed from this medicine's gallery.", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("CANCEL", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _images.removeAt(index);
                if (_displayImagePath == path) {
                  _displayImagePath = _images.isNotEmpty ? _images.first : null;
                }
              });
              Navigator.pop(ctx);
              ToastService.show(context, "Photo removed", isError: true);
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceOption({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }

  bool get _isSaveEnabled => _nameController.text.trim().isNotEmpty && _quantityController.text.trim().isNotEmpty;

  void _save() {
    if (!_isSaveEnabled) return;
    final provider = Provider.of<MedicineProvider>(context, listen: false);
    final String name = _nameController.text.trim();

    final bool isDuplicate = provider.medicines.any((m) =>
        m.name.toLowerCase().trim() == name.toLowerCase() &&
        m.id != widget.medicineToEdit?.id);

    if (isDuplicate) {
      ToastService.show(context, "Medicine '$name' is already in your list", isError: true);
      return;
    }

    final medicine = Medicine(
      id: widget.medicineToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      quantity: _quantityController.text.trim(),
      timingRule: _selectedRule,
      mealTime: _selectedMeal,
      notificationHour: _selectedTime.hour,
      notificationMinute: _selectedTime.minute,
      lastTakenDate: widget.medicineToEdit?.lastTakenDate,
      images: _images,
      displayImagePath: _displayImagePath,
    );

    if (widget.medicineToEdit != null) {
      provider.updateMedicine(medicine);
    } else {
      provider.addMedicineFull(medicine);
    }

    ToastService.show(context, widget.medicineToEdit != null ? "Changes saved successfully" : "New medicine added");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.medicineToEdit == null ? "New Medicine" : "Edit Medicine",
          style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: _isSaveEnabled ? Colors.blueAccent : theme.disabledColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                onPressed: _isSaveEnabled ? _save : null,
                child: const Text("SAVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel("MEDICINE PHOTOS"),
            const SizedBox(height: 12),
            _buildImageGallery(),
            const SizedBox(height: 32),
            _buildSectionLabel("MEDICATION DETAILS"),
            const SizedBox(height: 12),
            _buildInputCard(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _nameController,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: "Medicine Name",
                        hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.3)),
                        border: InputBorder.none,
                        icon: const Icon(Icons.medication_liquid, color: Colors.blueAccent),
                      ),
                    ),
                  ),
                  Container(height: 30, width: 1, color: theme.dividerColor),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _quantityController,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: "Qty",
                        hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.3), fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionLabel("SCHEDULE CONFIGURATION"),
            const SizedBox(height: 12),
            _buildInputCard(
              child: Column(
                children: [
                  _buildListSelector(
                    icon: Icons.event_repeat,
                    label: "Timing",
                    value: _selectedRule.displayName,
                    onTap: () => _showRulePicker(),
                  ),
                  Divider(color: theme.dividerColor.withOpacity(0.1), height: 1),
                  _buildListSelector(
                    icon: Icons.restaurant,
                    label: "Meal",
                    value: _selectedMeal.displayName,
                    onTap: () => _showMealPicker(),
                  ),
                  Divider(color: theme.dividerColor.withOpacity(0.1), height: 1),
                  _buildListSelector(
                    icon: Icons.alarm,
                    label: "Reminder Time",
                    value: _selectedTime.format(context),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: theme.colorScheme.copyWith(primary: Colors.blueAccent),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) setState(() => _selectedTime = picked);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _images.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _buildAddPhotoButton();

          final String path = _images[index - 1];
          final bool isDisplayImage = path == _displayImagePath;

          return GestureDetector(
            onTap: () => setState(() => _displayImagePath = path),
            onLongPress: () => _showImageOptions(path, index - 1),
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDisplayImage ? Colors.blueAccent : Colors.transparent,
                  width: 3,
                ),
                image: DecorationImage(
                  image: FileImage(File(path)),
                  fit: BoxFit.cover,
                ),
              ),
              child: isDisplayImage
                  ? const Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.check_circle, color: Colors.blueAccent, size: 22),
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withOpacity(0.2), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: Colors.blueAccent.withOpacity(0.6), size: 30),
            const SizedBox(height: 8),
            const Text("Add Photo", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), letterSpacing: 1.2));
  }

  Widget _buildInputCard({required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), 
            blurRadius: 15, 
            offset: const Offset(0, 8)
          )
        ],
      ),
      child: child,
    );
  }

  Widget _buildListSelector({required IconData icon, required String label, required String value, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Colors.blueAccent),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface)),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  void _showRulePicker() {
    _showModernBottomSheet(
      title: "Select Timing",
      items: TimingRule.values.map((r) => _buildPickerTile(r.displayName, () {
        setState(() => _selectedRule = r);
        Navigator.pop(context);
      })).toList(),
    );
  }

  void _showMealPicker() {
    _showModernBottomSheet(
      title: "Select Meal",
      items: MealTime.values.map((m) => _buildPickerTile(m.displayName, () {
        setState(() => _selectedMeal = m);
        Navigator.pop(context);
      })).toList(),
    );
  }

  void _showModernBottomSheet({required String title, required List<Widget> items}) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 20),
            ...items,
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerTile(String text, VoidCallback onTap) {
    return ListTile(
      title: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
      onTap: onTap,
    );
  }
}