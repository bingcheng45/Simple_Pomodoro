import 'dart:async';
import 'dart:ffi';
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
  final Function switchBGColor;

  Skeleton(this.switchBGColor);

  @override
  _SkeletonState createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> {
  int minute;
  int seconds;
  var now = DateTime.now();
  int _totalSeconds = 3; //actual total seconds to countdown
  int _start;
  int _current;
  bool isRunning = false;
  bool _btmTextVisible = true;
  bool firstTap = false;
  String pomodoroText = 'Tap to begin';
  String breakText = 'Take a short break!';
  double paddingheightTop = 0.0;
  double paddingheightBtm = 0.4;
  CountdownTimer countDownTimer;

  var timerObj;
  //start the countdown timer
  void startTimer() {
    isRunning = true;
    print('started');
    countDownTimer = new CountdownTimer(
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
    timerObj = sub;


    sub.onDone(() {
      onFinished();
      sub.cancel();
    });
  }

  void onFinished() {
    print("Done");
    isRunning = false;
    widget.switchBGColor();
    firstTap = false;
    setTimer();
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

  void setupTimer() {
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
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Material(
      color: globals.bgColor[globals.index],
      child: InkWell(
        splashColor: Colors.white54,
        onTap: () {
          //TODO:
          if (isRunning == false) {
            startTimer();
            setState(() {
              _btmTextVisible = !_btmTextVisible;
              Future.delayed(const Duration(milliseconds: 1000), () {
                _btmTextVisible = !_btmTextVisible;
                if (globals.index == 0) {
                  pomodoroText = 'Let\'s do it!';
                  breakText = 'Take a short break!';
                } else {
                  breakText = 'Go scroll Facebook';
                  pomodoroText = 'Tap to begin';
                }
              });
              if (!firstTap) {
                firstTap = !firstTap; //change first tap to true if false.
              }
            });
          }
        },
        onLongPress: () {
          onFinished();
          timerObj.cancel();
        },
        child: Container(
          height: height,
          width: width,
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.spaceAround,
            //mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              AnimatedContainer(
                padding: firstTap
                    ? EdgeInsets.only(top: height * 0.2)
                    : EdgeInsets.only(top: height * 0.0),
                duration: Duration(seconds: 2),
                curve: Curves.easeInOut,
                child: FittedBox(
                  child: topText(context),
                ),
              ),
              //SizedBox(height: MediaQuery.of(context).size.height*0.2,),
              AnimatedContainer(
                padding: firstTap
                    ? EdgeInsets.only(top: height * 0.2)
                    : EdgeInsets.only(top: height * 0.4),
                duration: Duration(seconds: 2),
                curve: Curves.easeInOut,
                child: FittedBox(
                  child: bottomText(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget topText(context) {
    double paddingW = MediaQuery.of(context).size.width * 0.1;
    //double paddingH = MediaQuery.of(context).size.height * paddingheightTop;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: paddingW),
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
    double paddingW = MediaQuery.of(context).size.width * 0.1;
    //double paddingH = MediaQuery.of(context).size.height * paddingheightBtm;
    return AnimatedOpacity(
      opacity: _btmTextVisible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 1000),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: paddingW),
        child: Opacity(
          opacity: 0.5,
          child: Text(
            (globals.index == 0) ? pomodoroText : breakText,
            style: TextStyle(
              color: Theme.of(context).textSelectionColor,
              fontSize: 54,
            ),
          ),
        ),
      ),
    );
  }
}
