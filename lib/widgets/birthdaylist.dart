import 'package:bday/storage/conservice.dart';
import 'package:bday/widgets/bday_blocs.dart';
import 'package:bday/widgets/search_widget.dart';
import 'package:confetti/confetti.dart';
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
  List<Birthday> _filteredBirthdays = [];
  bool _isLoading = true;
  String _searchQuery = '';
  late ConfettiController _confettiController;
  
  // Scroll-aware hiding variables
  late ScrollController _scrollController;
  bool _showStatistics = true;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 5));
    
    // Initialize scroll controller
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
    
    _loadBirthdays();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Handle scroll events to show/hide statistics
  void _handleScroll() {
    // Show stats only when at the very top (offset < 50 pixels)
    final isAtTop = _scrollController.offset < 50;
    
    if (isAtTop && !_showStatistics) {
      // Reached top - show statistics
      setState(() => _showStatistics = true);
    } else if (!isAtTop && _showStatistics) {
      // Scrolled down - hide statistics
      setState(() => _showStatistics = false);
    }
  }

  Future<void> _loadBirthdays() async {
  try {
    // Get birthdays from database
    final birthdays = HiveBirthdayService.getAllBirthdays();
    
    // Sort on main thread (fast enough for most cases)
    birthdays.sort((a, b) {
      if (a.isBirthdayToday && !b.isBirthdayToday) return -1;
      if (!a.isBirthdayToday && b.isBirthdayToday) return 1;
      if (a.isBirthdayToday && b.isBirthdayToday) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      return a.daysUntilBirthday.compareTo(b.daysUntilBirthday);
    });
    
    setState(() {
      _birthdays = birthdays;
      _filteredBirthdays = birthdays;
      _isLoading = false;
    });
   
    // Check for birthdays today and play confetti
    if (_birthdays.isNotEmpty &&
        _birthdays.any((b) => b.isBirthdayToday) &&
        SettingsService.getConfettiEnabled() &&
        SettingsService.shouldPlayConfettiToday()) {
      
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          _confettiController.play();
          
          // Mark confetti as played today
          final today = DateTime.now().toIso8601String().split('T')[0];
          await SettingsService.setLastConfettiDate(today);
        }
      });
    }
    
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

  // Filter birthdays based on search query
  void _filterBirthdays(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredBirthdays = _birthdays;
      } else {
        _filteredBirthdays = _birthdays
            .where((birthday) =>
                birthday.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
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
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          Column(
            children: [
              // Search Widget
              SearchWidget(
                onSearchChanged: _filterBirthdays,
              ),
              Expanded(
                child: _filteredBirthdays.isEmpty
                    ? _buildEmptySearchState(theme)
                    : _buildBirthdayList(theme),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 40,
              maxBlastForce: 20,
              minBlastForce: 5,
              emissionFrequency: 0.05,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchState(ThemeData theme) {
    if (_searchQuery.isEmpty && _birthdays.isEmpty) {
      // No birthdays at all
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
    } else {
      // Search returned no results
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 100,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'No matches found',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with a different name',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }

  Widget _buildBirthdayList(ThemeData theme) {
    // Pre-compute statistics once instead of computing during build
    final totalCount = _filteredBirthdays.length;
    final todayCount = _filteredBirthdays.where((b) => b.isBirthdayToday).length;
    final weekCount = _filteredBirthdays.where((b) => b.daysUntilBirthday <= 7).length;

    return RefreshIndicator(
      onRefresh: _refreshBirthdays,
      child: Column(
        children: [
          // Animated Statistics Card - Only shown when at top
          if (_showStatistics)
            AnimatedOpacity(
              opacity: _showStatistics ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
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
                      value: totalCount.toString(),
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
                      value: todayCount.toString(),
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
                      value: weekCount.toString(),
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ),
          // Birthday List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredBirthdays.length,
              itemBuilder: (context, index) {
                final birthday = _filteredBirthdays[index];
                return BirthdayCard(
                  key: ValueKey(birthday.key),
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