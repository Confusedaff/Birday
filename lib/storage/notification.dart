import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart'; 

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
    print("Device timezone: $timeZoneName → using $normalized");
    tz.setLocalLocation(tz.getLocation(normalized));
  } catch (e) {
    print("⚠️ Failed to get timezone, falling back to UTC. Error: $e");
    tz.setLocalLocation(tz.getLocation("UTC"));
  }

  const androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);

  await notificationsPlugin.initialize(initSettings);
  _isInitialized = true;

  final androidImplementation = notificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  final granted =
      await androidImplementation?.requestNotificationsPermission();

  if (granted != true) {
    print('Notification permission denied');
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
      await cancelNotification(birthdayKey.hashCode + i);
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
      print('Skipping past notification for $scheduledDate');
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
  } catch (e) {
    print('Error scheduling notification: $e');
  }
}

}