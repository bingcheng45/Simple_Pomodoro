import 'package:flutter/material.dart';
import 'package:simple_pomodoro/global.dart' as globals;
import 'package:simple_pomodoro/skeleton.dart';
import 'package:rect_getter/rect_getter.dart';

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
      body: Stack(
        children: <Widget>[
          Skeleton(switchBGColor),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            right: 0,
            child: FloatingActionButton(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              child: Icon(Icons.settings),
              onPressed: null,
            ),
          ),
        ],
      ),
    );
  }
}
