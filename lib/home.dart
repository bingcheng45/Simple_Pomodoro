import 'package:flutter/material.dart';
import 'package:simple_pomodoro/global.dart' as globals;
import 'package:simple_pomodoro/skeleton.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void switchBGColor() {
    setState(() {
      if (globals.index == 0) {
        globals.index = 1;
      } else {
        globals.index = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(

      //   elevation: 0.0,
      //   backgroundColor: globals.bgColor[globals.index],
      // ),
      body: Skeleton(switchBGColor),
    );
  }
}

