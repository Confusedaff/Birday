import 'package:bday/config/app_constants.dart';
import 'package:bday/pages/home.dart';
import 'package:bday/services/logger_service.dart';
import 'package:bday/storage/conservice.dart';
import 'package:bday/storage/hive_service.dart';
import 'package:bday/themes/themeprovider.dart';
import 'package:bday/widgets/remainder.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

/// Entry point for the Birthday Reminder Application.
///
/// Initializes all required services and providers before launching the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize database and services
    await _initializeServices();

    AppLogger.info('All services initialized successfully');

    // Launch the application
    runApp(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: const MyApp(),
      ),
    );

    // Schedule reminders after app renders (non-blocking)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BirthdayReminder.scheduleAllReminders().catchError((error) {
        AppLogger.error(
          'Failed to schedule reminders',
          error: error,
        );
      });
    });
  } catch (e, stackTrace) {
    AppLogger.error(
      'Fatal error during app initialization',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
}

/// Initializes all required services for the application.
///
/// This includes:
/// - Hive database initialization
/// - Theme settings
/// - Settings service
/// - Notification service (lazy-initialized post-frame to avoid UI lag)
Future<void> _initializeServices() async {
  AppLogger.info('Initializing services...');

  try {
    // Initialize Hive Flutter
    await Hive.initFlutter();
    AppLogger.debug('Hive initialized');

    // Open required Hive boxes
    await Hive.openBox(AppConstants.hiveThemeBoxName);
    AppLogger.debug('Theme box opened');

    // Initialize birthday service
    await HiveBirthdayService.init();
    AppLogger.debug('Birthday service initialized');

    // Initialize settings service
    await SettingsService.init();
    AppLogger.debug('Settings service initialized');

    // NOTE: Notification service is NOT initialized here to avoid blocking UI thread.
    // It will be lazily initialized on first use via NotiService singleton.
    // This significantly improves app startup time (avoids 2-3 second timezone lookup).
  } catch (e, stackTrace) {
    AppLogger.error(
      'Error during service initialization',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
}

/// Main application widget.
///
/// Sets up the Material app with theme support and navigation.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: AppConstants.appName,
      theme: themeProvider.themeData,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
