import 'package:bday/storage/hive_service.dart';
import 'package:bday/widgets/birthdaylist.dart';
import 'package:flutter/material.dart';
import 'package:bday/widgets/appbar.dart';
import 'package:bday/widgets/drawer.dart';
import 'package:bday/widgets/empty.dart';
import 'package:bday/widgets/floatingbutton.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(),
      drawer: const AppDrawer(),
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
      floatingActionButton: const Floatingbutton(),
    );
  }
}
