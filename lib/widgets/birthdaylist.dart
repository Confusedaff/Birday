import 'package:bday/storage/conservice.dart';
import 'package:bday/widgets/bday_blocs.dart';
import 'package:bday/widgets/search_widget.dart';
import 'package:bday/services/logger_service.dart';
import 'package:bday/config/app_constants.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:bday/storage/hive.dart';
import 'package:bday/storage/hive_service.dart';

/// Main screen displaying the list of birthdays.
///
/// This stateful widget provides:
/// - A scrollable list of all birthdays sorted by proximity
/// - Search/filter functionality
/// - Statistics showing total, today's, and upcoming birthdays
/// - Confetti animation for birthdays today
/// - Pull-to-refresh functionality
/// - Scroll-aware statistics bar that hides when scrolling
///
/// The widget automatically loads birthdays on init and handles
/// refresh after add/update/delete operations.
class BirthdayListScreen extends StatefulWidget {
  const BirthdayListScreen({super.key});

  @override
  State<BirthdayListScreen> createState() => _BirthdayListScreenState();
}

class _BirthdayListScreenState extends State<BirthdayListScreen> {
  /// All loaded birthdays from database.
  List<Birthday> _birthdays = [];

  /// Filtered birthdays based on current search query.
  List<Birthday> _filteredBirthdays = [];

  /// Whether data is currently being loaded.
  bool _isLoading = true;

  /// Current search query string.
  String _searchQuery = '';

  /// Controller for confetti animation.
  late ConfettiController _confettiController;

  /// Controller for scrolling the birthday list.
  late ScrollController _scrollController;

  /// Whether to show the statistics bar.
  ///
  /// The bar is hidden when user scrolls down (offset > 50px)
  /// and shown when scrolling back to the top.
  bool _showStatistics = true;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: AppConstants.confettiDuration,
    );

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

  /// Handles scroll events to show/hide the statistics bar.
  ///
  /// Shows statistics only when near the top of the list (offset < 50px).
  /// This prevents the statistics bar from covering the list while scrolling.
  void _handleScroll() {
    final isAtTop = _scrollController.offset < AppConstants.scrollTopThreshold;

    if (isAtTop && !_showStatistics) {
      setState(() => _showStatistics = true);
    } else if (!isAtTop && _showStatistics) {
      setState(() => _showStatistics = false);
    }
  }

  /// Loads all birthdays from the database.
  ///
  /// This method:
  /// 1. Fetches all birthdays from Hive storage
  /// 2. Sorts them by proximity to next birthday
  /// 3. Checks for birthdays today and triggers confetti if enabled
  /// 4. Updates UI with loaded data
  ///
  /// Errors are logged and displayed to user via SnackBar.
  Future<void> _loadBirthdays() async {
    try {
      // Get birthdays from database
      final birthdays = HiveBirthdayService.getAllBirthdays();

      // Sort birthdays:
      // 1. Today's birthdays first
      // 2. Then by days until next birthday
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

      AppLogger.info('Loaded ${birthdays.length} birthday(ies)');

      // Check for birthdays today and play confetti
      _triggerConfettiIfNeeded(birthdays);
    } catch (e) {
      AppLogger.error(
        'Failed to load birthdays',
        error: e,
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppConstants.errorLoadingBirthdays),
            backgroundColor: Colors.red,
            duration: AppConstants.longSnackBarDuration,
          ),
        );
      }
    }
  }

  /// Triggers confetti animation if conditions are met.
  ///
  /// Shows confetti if:
  /// 1. There are birthdays today
  /// 2. Confetti animations are enabled
  /// 3. Confetti hasn't been shown yet today
  ///
  /// Parameters:
  ///   - birthdays: The list of birthdays to check
  void _triggerConfettiIfNeeded(List<Birthday> birthdays) {
    if (birthdays.isNotEmpty &&
        birthdays.any((b) => b.isBirthdayToday) &&
        SettingsService.getConfettiEnabled() &&
        SettingsService.shouldPlayConfettiToday()) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          try {
            _confettiController.play();

            // Mark confetti as played today
            final today = DateTime.now().toIso8601String().split('T')[0];
            await SettingsService.setLastConfettiDate(today);

            AppLogger.debug('Confetti animation triggered');
          } catch (e) {
            AppLogger.error(
              'Error playing confetti animation',
              error: e,
            );
          }
        }
      });
    }
  }

  /// Filters birthdays based on search query.
  ///
  /// Updates the filtered list to only include birthdays whose names
  /// contain the search query (case-insensitive).
  ///
  /// Parameters:
  ///   - query: The search string to filter by
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

  /// Refreshes the birthday list.
  ///
  /// Called when user pulls to refresh or after add/update/delete operations.
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
          // Confetti Animation Layer
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

  /// Builds the empty state UI when no birthdays match the search.
  ///
  /// Shows different messages depending on whether the list is empty
  /// or if the search returned no results.
  ///
  /// Parameters:
  ///   - theme: The current theme to apply to the UI
  ///
  /// Returns: A Widget representing the empty state
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
              AppConstants.noBirthdaysYet,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppConstants.addFirstBirthday,
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
              AppConstants.noSearchResults,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppConstants.tryDifferentSearch,
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

  /// Builds the main birthday list widget.
  ///
  /// Displays:
  /// 1. Statistics bar (if scrolled to top)
  /// 2. Scrollable list of birthday cards
  /// 3. Pull-to-refresh functionality
  ///
  /// Parameters:
  ///   - theme: The current theme to apply to the UI
  ///
  /// Returns: A Widget containing the birthday list
  Widget _buildBirthdayList(ThemeData theme) {
    // Pre-compute statistics once instead of computing during build
    final totalCount = _filteredBirthdays.length;
    final todayCount =
        _filteredBirthdays.where((b) => b.isBirthdayToday).length;
    final weekCount =
        _filteredBirthdays.where((b) => b.daysUntilBirthday <= 7).length;

    return RefreshIndicator(
      onRefresh: _refreshBirthdays,
      child: Column(
        children: [
          // Animated Statistics Card - Only shown when at top
          if (_showStatistics)
            AnimatedOpacity(
              opacity: _showStatistics ? 1.0 : 0.0,
              duration: AppConstants.animationDuration,
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
                      label: AppConstants.totalLabel,
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
                      label: AppConstants.todayLabel,
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
                      label: AppConstants.thisWeekLabel,
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

  /// Builds a single statistic item for the statistics bar.
  ///
  /// Shows an icon, value, and label for a single statistic.
  ///
  /// Parameters:
  ///   - icon: The IconData to display
  ///   - label: The label text (e.g., "Total")
  ///   - value: The value to display (e.g., "42")
  ///   - theme: The current theme to apply styling
  ///
  /// Returns: A Widget representing the stat item
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