import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:bday/services/logger_service.dart';
import 'package:bday/config/app_constants.dart';

/// Service for managing local notifications in the Birthday Reminder app.
///
/// This is a singleton that handles all notification-related operations including:
/// - Initialization of the notification plugin
/// - Platform-specific permission requests
/// - Scheduling yearly birthday reminders
/// - Showing immediate notifications
/// - Canceling scheduled notifications
///
/// The service is timezone-aware and ensures notifications are shown in the device's
/// local timezone. It handles platform-specific initialization for both Android and iOS.
class NotiService {
  NotiService._internal();
  static final NotiService _instance = NotiService._internal();
  factory NotiService() => _instance;

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initializes the notification service.
  ///
  /// This method must be called before using any other notification methods.
  /// It handles:
  /// - Timezone initialization and device timezone detection
  /// - Android and iOS platform-specific setup
  /// - Notification permission requests
  ///
  /// Safe to call multiple times - subsequent calls are no-ops due to the
  /// [_isInitialized] guard.
  Future<void> initNotification() async {
    if (_isInitialized) return;

    try {
      _initializeTimeZone();
      _initializePlatforms();
      await _requestNotificationPermissions();
      _isInitialized = true;
      AppLogger.info('Notification service initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize notification service', error: e);
    }
  }

  /// Initializes timezone data and sets the local timezone.
  ///
  /// This method handles device timezone detection with fallback to UTC
  /// if timezone detection fails. It also handles deprecated timezone names.
  void _initializeTimeZone() {
    tz.initializeTimeZones();

    try {
      final String timeZoneName = FlutterTimezone.getLocalTimezone() as String;
      final normalized = _normalizeTimeZone(timeZoneName);
      AppLogger.debug(
        'Device timezone: $timeZoneName → using $normalized',
      );
      tz.setLocalLocation(tz.getLocation(normalized));
    } catch (e) {
      AppLogger.warning(
        'Failed to get timezone, falling back to UTC',
        error: e,
      );
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  /// Normalizes deprecated or alternative timezone names.
  ///
  /// Some devices may report timezone names that are no longer in use
  /// (e.g., "Asia/Calcutta" instead of "Asia/Kolkata"). This method
  /// handles such conversions.
  ///
  /// Parameters:
  ///   - name: The timezone name to normalize
  ///
  /// Returns: The normalized timezone name, or the original if no
  /// normalization is needed.
  String _normalizeTimeZone(String name) {
    switch (name) {
      case "Asia/Calcutta":
        return "Asia/Kolkata";
      default:
        return name;
    }
  }

  /// Initializes platform-specific notification settings.
  ///
  /// Sets up notification channels and permissions for both Android and iOS.
  void _initializePlatforms() {
    const androidSettings = AndroidInitializationSettings(
      '@drawable/notification_icon',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    notificationsPlugin.initialize(initSettings);
  }

  /// Requests notification permissions from both Android and iOS.
  ///
  /// This method handles platform-specific permission requests and logs
  /// the result of each permission request. It gracefully handles cases
  /// where the platform implementation is not available.
  Future<void> _requestNotificationPermissions() async {
    final androidImplementation = notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final iosImplementation = notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    await _requestAndroidPermissions(androidImplementation);
    await _requestIosPermissions(iosImplementation);
  }

  /// Requests Android notification permissions.
  ///
  /// Parameters:
  ///   - implementation: The Android platform implementation, or null if unavailable
  Future<void> _requestAndroidPermissions(
    AndroidFlutterLocalNotificationsPlugin? implementation,
  ) async {
    if (implementation == null) return;

    try {
      final granted = await implementation.requestNotificationsPermission();
      if (granted == true) {
        AppLogger.debug('Android notification permission granted');
      } else {
        AppLogger.warning('Android notification permission was denied');
      }
    } catch (e) {
      AppLogger.error(
        'Error requesting Android notification permissions',
        error: e,
      );
    }
  }

  /// Requests iOS notification permissions.
  ///
  /// Parameters:
  ///   - implementation: The iOS platform implementation, or null if unavailable
  Future<void> _requestIosPermissions(
    IOSFlutterLocalNotificationsPlugin? implementation,
  ) async {
    if (implementation == null) return;

    try {
      final granted = await implementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      ) ?? false;

      if (granted) {
        AppLogger.debug('iOS notification permissions granted');
      } else {
        AppLogger.warning('iOS notification permissions were denied');
      }
    } catch (e) {
      AppLogger.error(
        'Error requesting iOS notification permissions',
        error: e,
      );
    }
  }

  /// Creates the notification details used for displaying notifications.
  ///
  /// Returns a [NotificationDetails] object configured with:
  /// - Maximum importance and priority on Android
  /// - Sound and vibration enabled
  ///
  /// Returns: Configured [NotificationDetails] for the notification channel
  NotificationDetails _notificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  /// Cancels a scheduled notification by its ID.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the notification to cancel
  Future<void> cancelNotification(int id) async {
    try {
      await notificationsPlugin.cancel(id);
      AppLogger.debug('Canceled notification ID: $id');
    } catch (e) {
      AppLogger.error(
        'Error canceling notification ID: $id',
        error: e,
      );
    }
  }

  /// Cancels all reminders for a birthday (deprecated).
  ///
  /// This method is deprecated - use the new safe ID generation in BirthdayReminder.
  /// Kept for backward compatibility with older birthday data.
  ///
  /// Parameters:
  ///   - birthdayKey: The Hive key of the birthday
  @Deprecated(
    'Use BirthdayReminder.cancelBirthdayNotifications instead. '
    'This method will be removed in version 2.0.0',
  )
  Future<void> cancelBirthdayNotifications(int birthdayKey) async {
    try {
      for (int i = 0; i < 4; i++) {
        await cancelNotification(birthdayKey * 4 + i);
      }
      AppLogger.debug('Canceled all notifications for birthday key: $birthdayKey');
    } catch (e) {
      AppLogger.error(
        'Error canceling birthday notifications for key: $birthdayKey',
        error: e,
      );
    }
  }

  /// Shows an immediate notification.
  ///
  /// This is useful for testing notifications or showing urgent messages
  /// that don't need to be scheduled.
  ///
  /// Parameters:
  ///   - id: Unique identifier for the notification (default: 0)
  ///   - title: The notification title
  ///   - body: The notification body text
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    try {
      await notificationsPlugin.show(
        id,
        title,
        body,
        _notificationDetails(),
      );
      AppLogger.debug('Showed notification ID: $id - $title');
    } catch (e) {
      AppLogger.error(
        'Error showing notification ID: $id',
        error: e,
      );
    }
  }

  /// Schedules a yearly notification for a birthday.
  ///
  /// Schedules a notification to be shown on the same day and time every year.
  /// Automatically skips scheduling if the scheduled date is in the past.
  /// Uses the device's local timezone for scheduling.
  ///
  /// Parameters:
  ///   - id: Unique identifier for the notification
  ///   - title: The notification title
  ///   - body: The notification body text
  ///   - scheduledDate: The date and time when the notification should be shown
  ///
  /// Example:
  /// ```dart
  /// await notiService.scheduleYearlyNotification(
  ///   id: 123,
  ///   title: 'John\'s Birthday',
  ///   body: 'Today is John\'s birthday!',
  ///   scheduledDate: DateTime(2024, 3, 15, 9, 0),
  /// );
  /// ```
  Future<void> scheduleYearlyNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

      // Skip past notifications
      if (tzDate.isBefore(tz.TZDateTime.now(tz.local))) {
        AppLogger.debug(
          'Skipped scheduling past notification for $scheduledDate',
        );
        return;
      }

      await notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzDate,
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      );
      AppLogger.debug(
        'Scheduled yearly notification ID: $id for $scheduledDate',
      );
    } catch (e) {
      AppLogger.error(
        'Error scheduling notification ID: $id',
        error: e,
      );
    }
  }

}