import 'dart:io';

import 'package:bday/widgets/remainder.dart';
import 'package:bday/services/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:bday/storage/hive.dart';
import 'package:bday/storage/hive_service.dart';
import 'package:bday/widgets/timeselector.dart';
import 'package:image_picker/image_picker.dart';

/// A card widget that displays a single birthday.
///
/// This stateful widget provides:
/// - Birthday information display (name, age, days until birthday)
/// - Profile picture support with gallery picker
/// - Details dialog showing complete birthday information
/// - Reminder time configuration
/// - Edit and delete functionality
/// - Enable/disable reminders toggle
///
/// The card automatically updates when birthday data changes and
/// notifies parent widget via callbacks.
///
/// Usage:
/// ```dart
/// BirthdayCard(
///   birthday: birthdayObject,
///   onDelete: () => refreshBirthdaysList(),
///   onUpdate: () => refreshBirthdaysList(),
/// )
/// ```
class BirthdayCard extends StatefulWidget {
  /// The birthday data to display.
  final Birthday birthday;

  /// Callback when birthday is deleted.
  final VoidCallback? onDelete;

  /// Callback when birthday is updated.
  final VoidCallback? onUpdate;

  const BirthdayCard({
    super.key,
    required this.birthday,
    this.onDelete,
    this.onUpdate,
  });

  @override
  State<BirthdayCard> createState() => _BirthdayCardState();
}

class _BirthdayCardState extends State<BirthdayCard> {

  /// Picks a profile picture from gallery for the birthday.
  ///
  /// Allows user to select an image from their device and saves it
  /// to the birthday object. Updates UI after selection.
  ///
  /// Parameters:
  ///   - birthday: The birthday to add profile picture to
  Future<void> _pickProfilePicture(Birthday birthday) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        birthday.profileImagePath = pickedFile.path;
        await birthday.save();
        if (mounted) {
          setState(() {});
          AppLogger.debug('Profile picture updated for ${birthday.name}');
        }
      }
    } catch (e) {
      AppLogger.error('Error picking profile picture', error: e);
    }
  }
  
  /// Shows a detailed birthday information dialog.
  ///
  /// Displays:
  /// - Birthday name and date
  /// - Current age
  /// - Next birthday date
  /// - Custom reminder time (if set)
  ///
  /// Parameters:
  ///   - birthday: The birthday to show details for
  void _showBirthdayDetails(Birthday birthday) {
    try {
      final details = _computeBirthdayDetails(birthday);
      
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final theme = Theme.of(context);
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.cake_rounded,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    birthday.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Birth Date',
                  value: details['birthDate']!,
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.numbers_rounded,
                  label: 'Current Age',
                  value: details['age']!,
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.celebration_rounded,
                  label: 'Next Birthday',
                  value: details['nextBirthday']!,
                  theme: theme,
                ),
                if (birthday.alarmTime != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.alarm_rounded,
                    label: 'Reminder Time',
                    value: details['reminderTime']!,
                    theme: theme,
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      AppLogger.error('Error showing birthday details', error: e);
    }
  }

  /// Builds a single detail row for the birthday information dialog.
  ///
  /// Shows an icon, label, and value in a formatted row.
  ///
  /// Parameters:
  ///   - icon: The icon to display
  ///   - label: The label text (e.g., "Birth Date")
  ///   - value: The value text (e.g., "15 Mar 1990")
  ///   - theme: The current theme for styling
  ///
  /// Returns: A Widget containing the formatted detail row
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Computes formatted birthday details for display.
  ///
  /// Pre-computes details once to avoid repeated calculations.
  /// Handles special cases like birthdays today.
  ///
  /// Parameters:
  ///   - birthday: The birthday to compute details for
  ///
  /// Returns: A map with keys: 'birthDate', 'age', 'nextBirthday', 'reminderTime'
  Map<String, String> _computeBirthdayDetails(Birthday birthday) {
    return {
      'birthDate': birthday.formattedBirthDate,
      'age': '${birthday.age} years old',
      'nextBirthday': birthday.isBirthdayToday 
          ? 'Today! 🎉' 
          : '${birthday.daysUntilBirthday + 1} days (turning ${birthday.age})',
      'reminderTime': birthday.alarmTime != null 
          ? TimeUtils.formatTime(birthday.alarmTime!, false)
          : '',
    };
  }

  /// Shows the reminder settings bottom sheet.
  ///
  /// Allows user to:
  /// - Toggle reminders on/off
  /// - Set custom reminder time
  /// - Save changes with proper validation
  ///
  /// Parameters:
  ///   - birthday: The birthday to configure reminders for
  void _showReminderSettings(Birthday birthday) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReminderSettingsBottomSheet(
        birthday: birthday,
        onSave: (updatedBirthday) async {
          await _updateBirthday(updatedBirthday);
        },
      ),
    );
  }

  /// Updates a birthday in the database and reschedules reminders.
  ///
  /// Performs:
  /// 1. Finds the birthday in the database
  /// 2. Updates the birthday object
  /// 3. Reschedules reminders if changed
  /// 4. Shows success/error feedback
  ///
  /// Parameters:
  ///   - updatedBirthday: The updated birthday object
  Future<void> _updateBirthday(Birthday updatedBirthday) async {
    try {
      final allBirthdays = HiveBirthdayService.getAllBirthdays();
      final index = allBirthdays.indexWhere((b) => b.key == updatedBirthday.key);
      
      if (index != -1) {
        await HiveBirthdayService.updateBirthday(index, updatedBirthday);
        widget.onUpdate?.call();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reminder settings updated for ${updatedBirthday.name}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update reminder: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmDelete(Birthday birthday) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: theme.colorScheme.error,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text('Delete Birthday'),
            ],
          ),
          content: Text(
            'Are you sure you want to delete ${birthday.name}\'s birthday? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteBirthday(birthday);
              },
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteBirthday(Birthday birthday) async {
    final reminder = BirthdayReminder();
    await reminder.cancelBirthdayReminders(birthday);
    try {
      final allBirthdays = HiveBirthdayService.getAllBirthdays();
      final index = allBirthdays.indexWhere((b) => b.key == birthday.key);
      
      if (index != -1) {
        await HiveBirthdayService.deleteBirthday(index);
        widget.onDelete?.call();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${birthday.name}\'s birthday deleted'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete birthday: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final birthday = widget.birthday;
    
    // Pre-compute values to avoid recalculation during each rebuild
    final isBirthdayToday = birthday.isBirthdayToday;
    final daysUntilBirthday = birthday.daysUntilBirthday;
    final age = birthday.age;
    final profileImagePath = birthday.profileImagePath;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
            theme.colorScheme.secondaryContainer.withValues(alpha: 0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showBirthdayDetails(birthday),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildProfileAvatar(isBirthdayToday, profileImagePath, theme),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBirthdayInfo(isBirthdayToday, daysUntilBirthday, age, theme),
                ),
                _buildActionButtons(birthday, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(bool isBirthdayToday, String? profileImagePath, ThemeData theme) {
    return GestureDetector(
      onLongPress: () => _pickProfilePicture(widget.birthday),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isBirthdayToday 
              ? Colors.orange 
              : theme.colorScheme.primary,
          shape: BoxShape.circle,
          image: profileImagePath != null
              ? DecorationImage(
                  image: FileImage(File(profileImagePath)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: profileImagePath == null
            ? Icon(
                isBirthdayToday 
                    ? Icons.celebration_rounded 
                    : Icons.cake_rounded,
                color: Colors.white,
                size: 30,
              )
            : null,
      ),
    );
  }

  Widget _buildBirthdayInfo(bool isBirthdayToday, int daysUntilBirthday, int age, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          widget.birthday.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          isBirthdayToday
              ? 'Happy Birthday! 🎉'
              : '${daysUntilBirthday + 1} days until birthday',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          isBirthdayToday
              ? 'Now $age years old!'
              : 'Turning ${age + 1}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Birthday birthday, ThemeData theme) {
    return Column(
      children: [
        IconButton(
          icon: Icon(
            birthday.isReminderEnabled
                ? Icons.notifications_active_rounded
                : Icons.notifications_off_rounded,
            color: birthday.isReminderEnabled 
                ? theme.colorScheme.primary 
                : theme.colorScheme.outline,
          ),
          onPressed: () => _showReminderSettings(birthday),
          tooltip: 'Reminder Settings',
          iconSize: 24,
        ),
        IconButton(
          icon: Icon(
            Icons.delete_rounded,
            color: theme.colorScheme.error,
          ),
          onPressed: () => _confirmDelete(birthday),
          tooltip: 'Delete',
          iconSize: 24,
        ),
      ],
    );
  }
}

class _ReminderSettingsBottomSheet extends StatefulWidget {
  final Birthday birthday;
  final Function(Birthday) onSave;

  const _ReminderSettingsBottomSheet({
    required this.birthday,
    required this.onSave,
  });

  @override
  State<_ReminderSettingsBottomSheet> createState() => _ReminderSettingsBottomSheetState();
}

class _ReminderSettingsBottomSheetState extends State<_ReminderSettingsBottomSheet> {
  late bool _isReminderEnabled;
  late TimeOfDay? _reminderTime;
  //late DateTime? _reminderDate;

  @override
  void initState() {
    super.initState();
    _isReminderEnabled = widget.birthday.isReminderEnabled;
    _reminderTime = widget.birthday.alarmTime;
    //_reminderDate = widget.birthday.alarmDate;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Reminder Settings',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'for ${widget.birthday.name}',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Enable Birthday Reminder'),
            subtitle: const Text('Get notified on their birthday'),
            value: _isReminderEnabled,
            onChanged: (value) {
              setState(() {
                _isReminderEnabled = value;
                // Clear time if reminder is disabled
                if (!value) {
                  _reminderTime = null;
                }
              });
            },
          ),
          if (_isReminderEnabled) ...[
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.access_time_rounded),
              title: const Text('Reminder Time'),
              subtitle: Text(
                _reminderTime != null
                    ? TimeUtils.formatTime(_reminderTime!, false)
                    : 'Tap to set time',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final time = await CustomTimePicker.showCustomTimePicker(
                  context: context,
                  initialTime: _reminderTime ?? const TimeOfDay(hour: 9, minute: 0),
                  helpText: 'Set Birthday Reminder Time',
                );
                if (time != null) {
                  setState(() {
                    _reminderTime = time;
                  });
                }
              },
            ),
          ],
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: _saveSettings,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveSettings() async {
  try {
    // Update the existing Birthday object directly
    widget.birthday.isReminderEnabled = _isReminderEnabled;
    
    if (_isReminderEnabled && _reminderTime != null) {
      widget.birthday.setAlarmTime(_reminderTime!);
      widget.birthday.alarmDate = widget.birthday.nextBirthday;
    } else {
      widget.birthday.alarmTimeHour = null;
      widget.birthday.alarmTimeMinute = null;
      widget.birthday.alarmDate = null;
    }

    // Save to Hive
    await widget.birthday.save();

    // Schedule notifications after saving
    final reminder = BirthdayReminder();
    await reminder.scheduleBirthdayReminders(widget.birthday);

    // Call the onSave callback to refresh parent widget
    widget.onSave(widget.birthday);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isReminderEnabled 
              ? 'Reminder set for ${widget.birthday.name}'
              : 'Reminder disabled for ${widget.birthday.name}',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      Navigator.of(context).pop();
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save reminder: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
}