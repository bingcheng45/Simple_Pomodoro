import 'dart:async';
import 'package:quiver/async.dart';
import 'package:flutter/material.dart';
import 'package:simple_pomodoro/global.dart' as globals;

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
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: globals.bgColor[globals.index],
      ),
      body: Skeleton(switchBGColor),
    );
  }
}

class Skeleton extends StatefulWidget {
  Function switchBGColor;

  Skeleton(this.switchBGColor);

  @override
  _SkeletonState createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> {
  int minute;
  int seconds;
  var now = DateTime.now();
  int _totalSeconds = 10; //actual total seconds to countdown
  int _start;
  int _current;
  bool isRunning = false;

  //start the countdown timer
  void startTimer() {
    isRunning = true;
    print('started');
    CountdownTimer countDownTimer = new CountdownTimer(
      new Duration(seconds: _start),
      new Duration(seconds: 1),
    );

    var sub = countDownTimer.listen(null);
    sub.onData((duration) {
      setState(() {
        _current = _start - duration.elapsed.inSeconds;
        seconds = getSeconds(_current);
        minute = getMinute(_current);
      });
    });

    sub.onDone(() {
      print("Done");
      isRunning = false;
      widget.switchBGColor();
      setTimer();
      countDownTimer = new CountdownTimer(
        new Duration(seconds: _start),
        new Duration(seconds: 1),
      );
      sub.cancel();
    });
  }

  void setTimer() {
    setState(() {
      if (globals.index == 0) {
        _totalSeconds = 7;
      } else {
        _totalSeconds = 5;
      }
      setupTimer();
    });
  }

  String beautifyNumber(int num) {
    return num < 10 ? '0$num' : '$num';
  }

  int getMinute(int current) {
    return _current ~/ 60;
  }

  int getSeconds(int current) {
    return current % 60;
  }

  @override
  void initState() {
    super.initState();
    setupTimer();
    //Timer.periodic(Duration(seconds: 1), (Timer t) => _setTime());//runs forever
  }

  void setupTimer(){
    _start = _totalSeconds;
    _current = _totalSeconds;
    minute = getMinute(_totalSeconds);
    seconds = getSeconds(_totalSeconds);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: inkWellButton(context),
    );
  }

  Widget inkWellButton(context) {
    return Material(
      color: globals.bgColor[globals.index],
      child: InkWell(
        splashColor: Colors.white54,
        onTap: () {
          //TODO:
          if (isRunning == false) {
            startTimer();
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            topText(context),
            bottomText(context),
          ],
        ),
      ),
    );
  }

  Widget topText(context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.4, //0.22 is center
      ),
      child: Opacity(
        opacity: 1,
        child: Text(
          '${beautifyNumber(minute)} : ${beautifyNumber(seconds)}',
          style: TextStyle(
            color: Theme.of(context).textSelectionColor,
            fontSize: 78,
          ),
        ),
      ),
    );
  }

  Widget bottomText(context) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.18,
      ),
      child: Opacity(
        opacity: 0.5,
        child: Text(
          'Tap to begin',
          style: TextStyle(
            color: Theme.of(context).textSelectionColor,
            fontSize: 54,
          ),
        ),
      ),
    );
  }
}