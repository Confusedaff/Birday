import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bday/storage/hive.dart';
import 'package:bday/storage/hive_service.dart';
import 'package:bday/widgets/timeselector.dart';
import 'package:image_picker/image_picker.dart';

class BirthdayCard extends StatefulWidget {
  final Birthday birthday;
  final VoidCallback? onDelete;
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

Future<void> _pickProfilePicture(Birthday birthday) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    birthday.profileImagePath = pickedFile.path;
    await birthday.save();
    if (mounted) {
      setState(() {});
    }
  }
}
  
  void _showBirthdayDetails(Birthday birthday) {
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
              Text(
                birthday.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
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
                value: birthday.formattedBirthDate,
                theme: theme,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                icon: Icons.numbers_rounded,
                label: 'Current Age',
                value: '${birthday.age} years old',
                theme: theme,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                icon: Icons.celebration_rounded,
                label: 'Next Birthday',
                value: birthday.isBirthdayToday 
                    ? 'Today! 🎉' 
                    : '${birthday.daysUntilBirthday+1} days (turning ${birthday.age})',
                theme: theme,
              ),
              if (birthday.alarmTime != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.alarm_rounded,
                  label: 'Reminder Time',
                  value: TimeUtils.formatTime(birthday.alarmTime!, false),
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
  }

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
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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

  Future<void> _updateBirthday(Birthday updatedBirthday) async {
    try {
      // Find the index of this birthday in Hive
      final allBirthdays = HiveBirthdayService.getAllBirthdays();
      final index = allBirthdays.indexWhere((b) => b.key == updatedBirthday.key);
      
      if (index != -1) {
        await HiveBirthdayService.updateBirthday(index, updatedBirthday);
        // Remove local state update since we're using widget.birthday directly
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
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer.withOpacity(0.8),
            theme.colorScheme.secondaryContainer.withOpacity(0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
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
                GestureDetector(
                  onLongPress: () => _pickProfilePicture(birthday),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: birthday.isBirthdayToday 
                          ? Colors.orange 
                          : theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        // BoxShadow(
                        //   color: (birthday.isBirthdayToday 
                        //       ? Colors.orange 
                        //       : theme.colorScheme.primary).withOpacity(0.3),
                        //   blurRadius: 8,
                        //   offset: const Offset(0, 4),
                        // ),
                      ],
                      image: birthday.profileImagePath != null
                          ? DecorationImage(
                              image: FileImage(File(birthday.profileImagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: birthday.profileImagePath == null
                        ? Icon(
                            birthday.isBirthdayToday 
                                ? Icons.celebration_rounded 
                                : Icons.cake_rounded,
                            color: Colors.white,
                            size: 30,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10,),
                      Text(
                        birthday.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        birthday.isBirthdayToday
                            ? 'Happy Birthday! 🎉'
                            : '${birthday.daysUntilBirthday + 1} days until birthday',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        birthday.isBirthdayToday
                            ? 'Now ${birthday.age} years old!'
                            : 'Turning ${birthday.age + 1}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
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
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_rounded,
                        color: theme.colorScheme.error,
                      ),
                      onPressed: () => _confirmDelete(birthday),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
              color: theme.colorScheme.onSurface.withOpacity(0.7),
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
        // Set alarm date to the next birthday
        widget.birthday.alarmDate = widget.birthday.nextBirthday;
      } else {
        // Clear alarm data if reminder is disabled
        widget.birthday.alarmTimeHour = null;
        widget.birthday.alarmTimeMinute = null;
        widget.birthday.alarmDate = null;
      }

      // Save to Hive
      await widget.birthday.save();

      // Call the onSave callback to refresh parent widget
      widget.onSave(widget.birthday);
      
      if (mounted) {
        // Show success message
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