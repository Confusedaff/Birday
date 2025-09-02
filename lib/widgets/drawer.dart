import 'package:bday/widgets/settings.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: Column(
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cake_rounded,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Birthday App',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Drawer Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home_rounded,
                  title: 'Home',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.import_export_rounded,
                  title: 'Import/Export',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to import/export
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  onTap: () {
                    Navigator.push(
                    context,
                     MaterialPageRoute(
                    builder: (context) => const Settingspage(),
                    ));
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.help_rounded,
                  title: 'Help & Support',
                  onTap: () {
                    Navigator.pop(context);
                    _showHelpDialog(context);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.info_rounded,
                  title: 'About',
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
          ),
          
          // Footer
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Version 1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.cake_rounded,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('About Birthday App'),
          ],
        ),
        content: const Text(
          'Birthday App helps you remember and celebrate important birthdays. '
          'Never miss a birthday again with our easy-to-use reminder system.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.cake_rounded,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Help'),
          ],
        ),
        content: const Text(
         '   Thalle oru 10 roopa ido🥹',
         style: TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}