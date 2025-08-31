import 'package:flutter/material.dart';

class Draghandle extends StatelessWidget {
  final double width;
  const Draghandle({
    super.key,
    required this.width,
    });

  @override
  Widget build(BuildContext context) {
    return Container(
    width: width,
    height: 4,
    margin: EdgeInsets.only(top: 8, bottom:0),
    child: Divider(
      thickness: 4,
      color: Colors.grey[600],
    ),
  );
  }
}