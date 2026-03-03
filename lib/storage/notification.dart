import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart'; 

class _Logger {
  static void debug(String message) {
    print('[DEBUG] $message');
  }
  
  static void info(String message) {
    print('[INFO] $message');
  }
  
  static void warning(String message) {
    print('[WARN] $message');
  }
  
  static void error(String message, [Object? error]) {
    print('[ERROR] $message${error != null ? '\nError: $error' : ''}');
  }
  
  static void success(String message) {
    print('[SUCCESS] ✓ $message');
  }
}

class NotiService {
  NotiService._internal();
  static final NotiService _instance = NotiService._internal();
  factory NotiService() => _instance;

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initNotification() async {
  if (_isInitialized) return;

    String normalizeTimeZone(String name) {
    switch (name) {
      case "Asia/Calcutta":
        return "Asia/Kolkata";
      default:
        return name;
    }
  }

  tz.initializeTimeZones();

  try {
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    final normalized = normalizeTimeZone(timeZoneName);
    _Logger.info("Device timezone: $timeZoneName → using $normalized");
    tz.setLocalLocation(tz.getLocation(normalized));
  } catch (e) {
    _Logger.warning("Failed to get timezone, falling back to UTC. Error: $e");
    tz.setLocalLocation(tz.getLocation("UTC"));
  }

  const androidSettings =
      AndroidInitializationSettings('@drawable/notification_icon');
  
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await notificationsPlugin.initialize(initSettings);
  _isInitialized = true;

  // Request notification permissions
  await _requestNotificationPermissions();
}

  Future<void> _requestNotificationPermissions() async {
    final androidImplementation = notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    final iosImplementation = notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    // Request Android permissions
    if (androidImplementation != null) {
      try {
        final granted = await androidImplementation.requestNotificationsPermission();
        if (granted != true) {
          _Logger.warning("Android notification permission denied");
        } else {
          _Logger.success("Android notification permission granted");
        }
      } catch (e) {
        _Logger.error("Error requesting Android permissions", e);
      }
    }

    // Request iOS permissions
    if (iosImplementation != null) {
      try {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ?? false;
        if (!granted) {
          _Logger.warning("iOS notification permission denied");
        } else {
          _Logger.success("iOS notification permission granted");
        }
      } catch (e) {
        _Logger.error("Error requesting iOS permissions", e);
      }
    }
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'birthday_channel_id',
        'Birthday Notifications',
        channelDescription: 'Birthday Reminder Notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
    );
  }

  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }

  Future<void> cancelBirthdayNotifications(int birthdayKey) async {
    for (int i = 0; i < 4; i++) {
      // Use same deterministic ID calculation as in scheduleBirthdayReminders
      await cancelNotification(birthdayKey * 4 + i);
    }
  }

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    await notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails(),
    );
  }

 Future<void> scheduleYearlyNotification({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledDate,
}) async {
  try {
    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    if (tzDate.isBefore(tz.TZDateTime.now(tz.local))) {
      _Logger.debug('Skipping past notification for $scheduledDate');
      return;
    }

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
    _Logger.debug('Scheduled notification ID: $id for $scheduledDate');
  } catch (e) {
    _Logger.error('Error scheduling notification ID: $id', e);
  }
}

}