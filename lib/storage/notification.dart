import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotiService {
  NotiService._internal();
  static final NotiService _instance = NotiService._internal();
  factory NotiService() => _instance;

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initNotification() async {
    if (_isInitialized) return;

    // Timezone initialization (needed for scheduled notifications)
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await notificationsPlugin.initialize(initSettings);
    _isInitialized = true;

    final androidImplementation = notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'birthday_channel_id',
        'Birthday Notifications',
        channelDescription: 'Birthday Reminder Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  // Show immediate notification
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
  final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

  await notificationsPlugin.zonedSchedule(
    id,
    title,
    body,
    tzDate,
    notificationDetails(),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.dateAndTime, 
  );
}
}
