import 'package:bday/storage/hive_service.dart';
import 'package:bday/widgets/birthdaylist.dart';
import 'package:flutter/material.dart';
import 'package:bday/widgets/appbar.dart';
import 'package:bday/widgets/drawer.dart';
import 'package:bday/widgets/empty.dart';
import 'package:bday/widgets/floatingButton.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  bool hasBirthdays = false;

  @override
  void initState() {
    super.initState();
    _checkHive();
  }

  Future<void> _checkHive() async {
    final hasData = HiveBirthdayService.hasBirthdays(); 
    setState(() {
      isLoading = false;
      hasBirthdays = hasData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Appbar(),
      drawer: AppDrawer(),
      body: ValueListenableBuilder(
        valueListenable: HiveBirthdayService.box.listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Empty();
          } else {
            return const BirthdayListScreen();
          }
        },
      ),
      floatingActionButton:Floatingbutton(),//FloatingActionButton(
      //   onPressed:() {
      //    NotiService().showNotification(
      // title: "Hello 🎉",
      // body: "This is a test notification",);
      //   }
      //   )
    );
  }
}
