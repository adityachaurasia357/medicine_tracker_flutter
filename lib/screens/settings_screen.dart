import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../state/medicine_provider.dart';
import '../state/theme_provider.dart'; 
import '../core/constants.dart';
import '../core/toast_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Helper method to format the medication list for sharing
  String _formatMedList(BuildContext context) {
    final provider = Provider.of<MedicineProvider>(context, listen: false);
    final meds = provider.medicines;

    if (meds.isEmpty) return "";

    String clipboardText = "📋 My Medication List:\n"
        "Generated via Medicine Tracker\n"
        "--------------------------\n\n";
    for (var med in meds) {
      clipboardText += "💊 ${med.name} (Qty: ${med.quantity})\n";
      clipboardText += "   • When: ${med.timingRule.displayName} ${med.mealTime.displayName}\n";
      clipboardText += "   • Time: ${med.notificationHour.toString().padLeft(2, '0')}:${med.notificationMinute.toString().padLeft(2, '0')}\n\n";
    }
    return clipboardText;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Settings",
          style: TextStyle(
            color: theme.colorScheme.onSurface, 
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          // --- SECTION 1: APPEARANCE ---
          _buildSectionHeader("APPEARANCE"),
          _buildSettingsCard(context, [
            _buildSettingsTile(
              context,
              icon: Icons.palette_rounded,
              iconColor: Colors.purpleAccent,
              title: "App Theme",
              subtitle: themeProvider.themeName,
              onTap: () => _showThemePicker(context),
            ),
          ]),

          const SizedBox(height: 24),

          // --- SECTION 2: SHARING & EXPORT ---
          _buildSectionHeader("SHARING & EXPORT"),
          _buildSettingsCard(context, [
            _buildSettingsTile(
              context,
              icon: Icons.share_rounded,
              iconColor: Colors.blueAccent,
              title: "Share with Doctor",
              subtitle: "Send list via WhatsApp or Email",
              onTap: () {
                final text = _formatMedList(context);
                if (text.isNotEmpty) {
                  Share.share(text, subject: 'My Medication List');
                } else {
                  ToastService.show(context, "Your medication list is empty!", isError: true);
                }
              },
            ),
            _buildDivider(context),
            _buildSettingsTile(
              context,
              icon: Icons.copy_all_rounded,
              iconColor: Colors.orangeAccent,
              title: "Copy to Clipboard",
              subtitle: "Manual copy for messages",
              onTap: () {
                final text = _formatMedList(context);
                if (text.isNotEmpty) {
                  Clipboard.setData(ClipboardData(text: text));
                  ToastService.show(context, "List copied to clipboard!");
                } else {
                  ToastService.show(context, "Nothing to copy!", isError: true);
                }
              },
            ),
          ]),

          const SizedBox(height: 24),

          // --- SECTION 3: APP INFO ---
          _buildSectionHeader("APP INFORMATION"),
          _buildSettingsCard(context, [
            _buildSettingsTile(
              context,
              icon: Icons.info_outline_rounded,
              iconColor: Colors.blueGrey,
              title: "Version",
              subtitle: "1.0.0 (Stable)",
              onTap: null,
            ),
            _buildDivider(context),
            _buildSettingsTile(
              context,
              icon: Icons.favorite_rounded,
              iconColor: Colors.redAccent,
              title: "Made for Dad",
              subtitle: "With ❤️ by his son",
              onTap: null,
            ),
          ]),
          
          const SizedBox(height: 40),
          Center(
            child: Text(
              "Medicine Tracker v1.0",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showThemePicker(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, 
              height: 4, 
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade300, 
                borderRadius: BorderRadius.circular(2)
              )
            ),
            const SizedBox(height: 24),
            Text(
              "Select Appearance", 
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              )
            ),
            const SizedBox(height: 24),
            // Updated options: Only Normal and Dark
            _buildThemeOption(context, "Normal (Light)", Icons.light_mode_rounded, ThemeMode.light, themeProvider),
            _buildThemeOption(context, "Dark Mode", Icons.dark_mode_rounded, ThemeMode.dark, themeProvider),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, String label, IconData icon, ThemeMode mode, ThemeProvider provider) {
    final isSelected = provider.themeMode == mode;
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blueAccent : Colors.grey),
      title: Text(
        label, 
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: theme.colorScheme.onSurface,
        )
      ),
      trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blueAccent) : null,
      onTap: () {
        provider.setThemeMode(mode);
        Navigator.pop(context);
        ToastService.show(context, "Theme updated to $label");
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.2 : 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1, 
      indent: 70, 
      endIndent: 20, 
      color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade100
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold, 
          fontSize: 16, 
          color: theme.colorScheme.onSurface
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
      ),
      trailing: onTap != null
          ? const Icon(Icons.chevron_right_rounded, color: Colors.grey)
          : null,
      onTap: onTap,
    );
  }
}