import 'package:bday/themes/themeprovider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Settingspage extends StatefulWidget {
  const Settingspage({super.key});

  @override
  State<Settingspage> createState() => _SettingspageState();
}

class _SettingspageState extends State<Settingspage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
            "Settings",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primaryContainer.withOpacity(0.3),
                theme.colorScheme.secondaryContainer.withOpacity(0.2),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Theme Settings Section
            _buildSettingsSection(
              context,
              title: "Appearance",
              children: [
                _buildSettingsTile(
                  context,
                  icon: themeProvider.isDarkmode 
                      ? Icons.dark_mode_rounded 
                      : Icons.light_mode_rounded,
                  title: themeProvider.isDarkmode 
                      ? "Dark Mode" 
                      : "Light Mode",
                  subtitle: themeProvider.isDarkmode 
                      ? "Currently using dark theme" 
                      : "Currently using light theme",
                  trailing: CupertinoSwitch(
                    value: themeProvider.isDarkmode,
                    onChanged: (value) => themeProvider.toggleTheme(),
                    activeColor: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // General Settings Section
            _buildSettingsSection(
              context,
              title: "General",
              children: [
                _buildSettingsTile(
                  context,
                  icon: Icons.notifications_rounded,
                  title: "Notifications",
                  subtitle: "Manage birthday reminders",
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  onTap: () {
                    // Handle notifications settings
                  },
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.language_rounded,
                  title: "Language",
                  subtitle: "English",
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  onTap: () {
                    // Handle language settings
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Data Settings Section
            _buildSettingsSection(
              context,
              title: "Data",
              children: [
                _buildSettingsTile(
                  context,
                  icon: Icons.backup_rounded,
                  title: "Backup & Restore",
                  subtitle: "Keep your birthdays safe",
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  onTap: () {
                    // Handle backup settings
                  },
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.delete_outline_rounded,
                  title: "Clear Data",
                  subtitle: "Remove all birthdays",
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.red,
                  ),
                  titleColor: Colors.red,
                  onTap: () {
                    _showClearDataDialog(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: theme.colorScheme.surface,
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: titleColor ?? theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: titleColor ?? theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: Colors.red,
            ),
            const SizedBox(width: 8),
            const Text('Clear All Data'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete all birthdays? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle clear data action
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All data cleared'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}