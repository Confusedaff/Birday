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
  await _startApp();
}

Future<void> _startApp() async {
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
    // This is most commonly a corrupted or schema-incompatible local
    // database (e.g. after an app update). Rather than letting the
    // exception propagate out of main() - which crashes the app with no
    // UI and no way for the user to recover other than uninstalling - show
    // a minimal error screen that lets them reset local data and retry.
    runApp(_StartupErrorApp(onRetry: _resetAndRetry));
  }
}

Future<bool> _resetAndRetry() async {
  try {
    await Hive.deleteFromDisk();
    await _initializeServices();
    AppLogger.info('Recovered after resetting local storage');
    return true;
  } catch (e, stackTrace) {
    AppLogger.error(
      'Reset & retry also failed',
      error: e,
      stackTrace: stackTrace,
    );
    return false;
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
      // The app manages light/dark mode itself via ThemeProvider (see the
      // toggle in Settings), rather than following the OS setting, so the
      // mode is set explicitly here to match - there is no separate
      // `darkTheme` registered, so `ThemeMode.system` would have had no
      // actual effect anyway and only implied a behavior the app doesn't
      // have.
      themeMode: themeProvider.isDarkmode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

/// Minimal fallback UI shown only if the app fails to start (e.g. a
/// corrupted local database). Offers a way to reset local data and retry
/// instead of leaving the user with a hard crash and no recovery path.
class _StartupErrorApp extends StatefulWidget {
  final Future<bool> Function() onRetry;

  const _StartupErrorApp({required this.onRetry});

  @override
  State<_StartupErrorApp> createState() => _StartupErrorAppState();
}

class _StartupErrorAppState extends State<_StartupErrorApp> {
  bool _retrying = false;
  bool _retryFailed = false;

  Future<void> _handleRetry() async {
    setState(() {
      _retrying = true;
      _retryFailed = false;
    });

    final success = await widget.onRetry();

    if (success) {
      // Replace this fallback screen with the real app now that
      // initialization has succeeded.
      runApp(
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          child: const MyApp(),
        ),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        BirthdayReminder.scheduleAllReminders().catchError((error) {
          AppLogger.error('Failed to schedule reminders', error: error);
        });
      });
      return;
    }

    if (mounted) {
      setState(() {
        _retrying = false;
        _retryFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong starting the app',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This can happen if your local data became corrupted, '
                    'often after an update. Resetting will clear saved '
                    'birthdays and let the app start fresh.',
                    textAlign: TextAlign.center,
                  ),
                  if (_retryFailed) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'The reset attempt also failed. Please try reinstalling the app.',
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _retrying ? null : _handleRetry,
                    child: _retrying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Reset & Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
