import 'package:bday/widgets/bday_blocs.dart';
import 'package:flutter/material.dart';
import 'package:bday/storage/hive.dart';
import 'package:bday/storage/hive_service.dart';

class BirthdayListScreen extends StatefulWidget {
  const BirthdayListScreen({super.key});

  @override
  State<BirthdayListScreen> createState() => _BirthdayListScreenState();
}

class _BirthdayListScreenState extends State<BirthdayListScreen> {
  List<Birthday> _birthdays = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBirthdays();
  }

  Future<void> _loadBirthdays() async {
    try {
      final birthdays = HiveBirthdayService.getAllBirthdays();
      // Sort birthdays by upcoming birthday date
      birthdays.sort((a, b) => a.daysUntilBirthday.compareTo(b.daysUntilBirthday));
      
      setState(() {
        _birthdays = birthdays;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load birthdays: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshBirthdays() async {
    await _loadBirthdays();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: _birthdays.isEmpty 
          ? _buildEmptyState(theme)
          : _buildBirthdayList(theme),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cake_outlined,
            size: 100,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 24),
          Text(
            'No Birthdays Yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first birthday to get started!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBirthdayList(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _refreshBirthdays,
      child: Column(
        children: [
          // Stats header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.secondary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.people_rounded,
                  label: 'Total',
                  value: _birthdays.length.toString(),
                  theme: theme,
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
                _buildStatItem(
                  icon: Icons.celebration_rounded,
                  label: 'Today',
                  value: _birthdays.where((b) => b.isBirthdayToday).length.toString(),
                  theme: theme,
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
                _buildStatItem(
                  icon: Icons.upcoming_rounded,
                  label: 'This Week',
                  value: _birthdays.where((b) => b.daysUntilBirthday <= 7).length.toString(),
                  theme: theme,
                ),
              ],
            ),
          ),
          
          // Birthday list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _birthdays.length,
              itemBuilder: (context, index) {
                final birthday = _birthdays[index];
                return BirthdayCard(
                  birthday: birthday,
                  onDelete: _refreshBirthdays,
                  onUpdate: _refreshBirthdays,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}