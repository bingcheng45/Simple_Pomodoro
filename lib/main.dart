
import 'package:flutter/material.dart';
import 'package:simple_pomodoro/home.dart';



void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Pomodoro',
      theme: ThemeData(
        primaryColor: Color(0xfffd9193),
        textSelectionColor: Colors.white,
        primaryColorDark: Color(0xff68c89c),
      ),
      home: Home(),
    );
  }
}


