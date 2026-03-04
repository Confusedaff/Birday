import 'package:bday/pages/home.dart';
import 'package:bday/storage/conservice.dart';
import 'package:bday/storage/hive_service.dart';
import 'package:bday/storage/notification.dart';
import 'package:bday/themes/themeprovider.dart';
import 'package:bday/widgets/remainder.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize in parallel where possible
  await Hive.initFlutter();
  await Hive.openBox('theme');        
  await HiveBirthdayService.init(); 
  await SettingsService.init();
  await NotiService().initNotification();
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
  
  // Schedule reminders AFTER app starts (non-blocking)
  WidgetsBinding.instance.addPostFrameCallback((_) {
    BirthdayReminder.scheduleAllReminders().catchError((error) {
      print('[ERROR] Error scheduling reminders: $error');
    });
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Birthday App',
      theme: themeProvider.themeData,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
