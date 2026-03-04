import 'package:flutter/foundation.dart';
import 'package:bday/config/app_constants.dart';

/// Production-grade logging service for the Birthday Reminder App.
///
/// This logger provides consistent logging across the application with
/// different log levels (debug, info, warning, error). Logs are only
/// output in debug mode to minimize production overhead.
class AppLogger {
  // Prevent instantiation
  AppLogger._();

  /// Logs a debug message.
  ///
  /// Debug logs are only shown in debug mode and provide detailed
  /// information useful for development and troubleshooting.
  static void debug(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, error: error, stackTrace: stackTrace);
  }

  /// Logs an informational message.
  ///
  /// Info logs are used for general application flow and state changes.
  static void info(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, error: error, stackTrace: stackTrace);
  }

  /// Logs a warning message.
  ///
  /// Warning logs indicate potentially problematic situations that don't
  /// prevent the app from functioning.
  static void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, error: error, stackTrace: stackTrace);
  }

  /// Logs an error message.
  ///
  /// Error logs indicate serious problems that may affect functionality.
  /// Should always include the error object and stack trace when available.
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, error: error, stackTrace: stackTrace);
  }

  /// Internal logging implementation.
  ///
  /// Only outputs logs in debug mode to minimize production performance impact.
  static void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;

    final timestamp = _getTimestamp();
    final emoji = level.emoji;
    final label = level.label;

    // Format: [HH:MM:SS] emoji LABEL: message
    print('[$timestamp] $emoji $label: $message');

    if (error != null) {
      print('  Error: $error');
    }

    if (stackTrace != null) {
      print('  StackTrace: $stackTrace');
    }
  }

  /// Returns current time in HH:MM:SS format.
  static String _getTimestamp() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
  }
}
