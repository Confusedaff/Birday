# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-03-04

### Added
- Initial release of Birthday Reminder App
- Birthday management with add, edit, and delete functionality
- Custom reminder times for each birthday
- Multiple reminder notifications (30 days, 15 days, 1 day, and day-of)
- Real-time search functionality for birthdays
- Confetti animation for birthday celebrations
- Profile picture support for birthdays
- Dark and light theme support
- Statistics dashboard showing total, today's, and upcoming birthdays
- Scroll-aware UI with statistics bar that hides during scrolling
- Pull-to-refresh functionality
- Settings screen for customizing notifications and animations
- Timezone-aware notification scheduling
- Production-grade logging service
- Comprehensive error handling and user feedback
- MIT License

### Fixed
- Fixed random 9 AM notifications caused by unsafe Hive key casting
- Fixed past reminders being scheduled incorrectly
- Fixed app startup performance issues by moving reminder scheduling to post-frame callback
- Fixed statistics bar overlapping content when scrolling

### Technical Details
- Built with Flutter and Dart
- Uses Hive for local data storage
- Flutter Local Notifications for reminder management
- Timezone support with flutter_timezone
- Responsive design for all screen sizes
- Optimized widget rebuilds to minimize performance impact

## Development Notes

### Architecture
- **Services**: Centralized business logic with singleton pattern
  - `HiveBirthdayService`: Birthday data persistence
  - `NotiService`: Notification scheduling and management
  - `BirthdayReminder`: Reminder scheduling logic
  - `SettingsService`: User preferences and settings
  - `AppLogger`: Production-grade logging
  
- **Widgets**: Reusable UI components
  - `BirthdayListScreen`: Main list view
  - `BirthdayCard`: Individual birthday display
  - `SearchWidget`: Search and filter functionality
  - Various dialogs and pickers for user input

- **Storage**: Data models
  - `Birthday`: Main data model with computed properties
  - Hive adapters for type-safe database access

### Constants
All magic numbers, strings, and configuration values are centralized in `AppConstants` for easy maintenance.

### Logging
The app uses `AppLogger` which:
- Only outputs in debug mode
- No console spam in release builds
- Consistent formatting across the app
- Log levels: debug, info, warning, error

### Known Limitations
- Notifications require appropriate OS-level permissions
- Timezone detection uses device locale
- Sorting is performed on main thread (acceptable for typical use)
