import 'package:flutter/material.dart';
import 'package:bday/config/app_constants.dart';

/// A search widget that provides real-time filtering of birthdays.
///
/// This widget provides:
/// - Real-time search with live filtering (case-insensitive)
/// - Smooth animations for expanding/collapsing
/// - Clear button to quickly reset search
/// - Helpful hint text when searching
/// - Customizable placeholder text
///
/// The widget calls [onSearchChanged] callback as the user types,
/// allowing the parent to update the filtered list in real-time.
///
/// Usage:
/// ```dart
/// SearchWidget(
///   onSearchChanged: (query) {
///     // Update filtered list based on query
///   },
///   placeholder: 'Search birthdays...',
/// )
/// ```
///
/// The widget automatically handles:
/// - Text field focus and animation
/// - Clearing search text
/// - Lowercase conversion for case-insensitive search
class SearchWidget extends StatefulWidget {
  /// Callback function when search text changes.
  ///
  /// Called with the lowercase search query as the user types.
  final Function(String) onSearchChanged;

  /// Placeholder text to show in the search field.
  ///
  /// Defaults to 'Search birthdays...' if not provided.
  final String placeholder;

  const SearchWidget({
    super.key,
    required this.onSearchChanged,
    this.placeholder = AppConstants.searchPlaceholder,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget>
    with SingleTickerProviderStateMixin {
  /// Controller for the search text field.
  late TextEditingController _searchController;

  /// Controller for the expand/collapse animation.
  late AnimationController _animationController;

  /// Fade animation for the hint text.
  late Animation<double> _fadeAnimation;

  /// Whether the search widget is currently expanded for searching.
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _animationController = AnimationController(
      duration: AppConstants.animationDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: AppConstants.animationDuration,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      height: _isSearching ? 70 : 50,
      child: Column(
        children: [
          // Search Input Bar
          _buildSearchBar(theme),
          // Subtle hint when searching
          if (_isSearching && _searchController.text.isEmpty)
            _buildSearchHint(theme),
        ],
      ),
    );
  }

  /// Builds the search input bar with gradient background.
  ///
  /// Features:
  /// - Gradient background matching app theme
  /// - Subtle shadow for depth
  /// - Search icon
  /// - Clear button (only shown when text exists)
  /// - Real-time text input handling
  ///
  /// Parameters:
  ///   - theme: The current theme to apply styling
  ///
  /// Returns: A Widget containing the search input bar
  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
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
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.search_rounded,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                widget.onSearchChanged(value.toLowerCase());
                _handleSearchStateChange();
              },
              onTap: () {
                _handleSearchStateChange();
              },
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
              ),
              cursorColor: theme.colorScheme.primary,
            ),
          ),
          // Clear button - only shown when text is present
          if (_searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(
                  Icons.clear_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                onPressed: () {
                  _searchController.clear();
                  widget.onSearchChanged('');
                  _handleSearchStateChange();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 20,
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the hint text shown when user enters search mode.
  ///
  /// The hint fades in and out with the search animation to provide
  /// helpful guidance without cluttering the UI.
  ///
  /// Parameters:
  ///   - theme: The current theme to apply styling
  ///
  /// Returns: A Widget containing the hint text with fade animation
  Widget _buildSearchHint(ThemeData theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          AppConstants.searchHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  /// Handles transitions between search and normal modes.
  ///
  /// This method manages:
  /// - Expanding/collapsing the search widget
  /// - Starting/stopping the fade animation for the hint text
  /// - Updating UI state
  void _handleSearchStateChange() {
    final hasText = _searchController.text.isNotEmpty;
    final shouldBeSearching = hasText || _searchController.text.isEmpty && _isSearching;

    if (shouldBeSearching && !_isSearching) {
      _animationController.forward();
      setState(() => _isSearching = true);
    } else if (!hasText && _isSearching && _searchController.text.isEmpty) {
      // Keep searching mode active if field is focused
      if (_searchController.text.isNotEmpty) {
        return;
      }
    }
  }
}
