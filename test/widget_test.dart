// Smoke tests for the Birthday app.
//
// The app relies on Hive (a local database) being initialized before any
// screen can render, and on a ThemeProvider being available above MyApp in
// the widget tree (see main.dart). These tests set both up against an
// isolated temporary directory so they don't touch real app data and can
// run repeatably in CI.

import 'dart:io';

import 'package:bday/main.dart';
import 'package:bday/storage/hive.dart';
import 'package:bday/storage/hive_service.dart';
import 'package:bday/storage/conservice.dart';
import 'package:bday/themes/themeprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('bday_test_');
    Hive.init(tempDir.path);
    await HiveBirthdayService.init();
    await SettingsService.init();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Widget buildTestApp() {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    );
  }

  testWidgets('shows the empty state when there are no birthdays',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('No Birthdays Yet'), findsOneWidget);
  });

  testWidgets('shows a saved birthday in the list',
      (WidgetTester tester) async {
    await HiveBirthdayService.addBirthday(
      Birthday(name: 'Ada Lovelace', birthDate: DateTime(1990, 12, 10)),
    );

    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Ada Lovelace'), findsOneWidget);
    expect(find.text('No Birthdays Yet'), findsNothing);
  });
}
