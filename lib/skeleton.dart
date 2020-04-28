import 'package:flutter/cupertino.dart';
import 'package:simple_pomodoro/global.dart' as globals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:quiver/async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Skeleton extends StatefulWidget {
  final Function switchBGColor;

  Skeleton(this.switchBGColor);
  @override
  _SkeletonState createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> {
  int minute = 0;
  int seconds = 0;
  int bMinute = 0;
  int bSeconds = 0;
  var now = DateTime.now();
  int _totalSeconds = 25 * 60; //actual total seconds to countdown
  int _start = 0;
  int _current = 0;
  bool _btmTextVisible = true;
  bool firstTap = false;
  String pomodoroText = 'Tap to begin';
  String breakText = 'Take a short break!';
  double paddingheightTop = 0.0;
  double paddingheightBtm = 0.4;
  CountdownTimer countDownTimer;
  final hKeyW = 'hour_key_work';
  final mKeyW = 'minute_key_work';

  //notification
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid;
  var initializationSettingsIOS;
  var initializationSettings;

  void _showNotification() async {
    await _demoNotification2();
  }

  Future<void> _demoNotification2() async {
    var scheduledNotificationDateTime =
        DateTime.now().add(Duration(seconds: _totalSeconds));
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your other channel id',
        'your other channel name',
        'your other channel description');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        0,
        'Simple Pomodoro',
        'Break Time is over!',
        scheduledNotificationDateTime,
        platformChannelSpecifics);
  }

  Future<void> _demoNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channel_ID', 'channel name', 'channel description',
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'test ticker');

    var iOSChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(0, 'Hello, buddy',
        'A message from flutter buddy', platformChannelSpecifics,
        payload: 'test oayload');
  }

  //end of notification

  void refreshTotalSeconds() {
    _getTotalSeconds().then((totalSeconds) {
      setState(() {
        _totalSeconds = totalSeconds;
        print('total seconds now $_totalSeconds earlier');
        setupTimer();
      });
    });
  }

  @override
  void initState() {
    super.initState();

    refreshTotalSeconds();
    globals.globalTimer = _totalSeconds;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: globals.bgColor[globals.index]),
    );

    initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    //Timer.periodic(Duration(seconds: 1), (Timer t) => _setTime());//runs forever
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('Notification payload: $payload');
    }
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => SecondRoute()));
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text(title),
              content: Text(body),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('Ok'),
                  onPressed: () async {
                    Navigator.of(context, rootNavigator: true).pop();
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SecondRoute()));
                  },
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: inkWellButton(context),
    );
  }

  Future<int> _getTotalSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    int hour = prefs.getInt(hKeyW) ?? 0;
    int minute = prefs.getInt(mKeyW) ?? 25;

    return Duration(hours: hour, minutes: minute).inSeconds;
  }

  var timerObj;
  //start the countdown timer
  void startTimer() {
    countDownTimer = new CountdownTimer(
      new Duration(seconds: _start),
      new Duration(seconds: 1),
    );

    var sub = countDownTimer.listen(null);
    sub.onData((duration) {
      setState(() {
        globals.isRunning = true;
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
    setState(() {
      globals.isRunning = false;
      widget.switchBGColor();
      firstTap = false;
    });

    setTimer();
  }

  void setTimer() {
    setState(() {
      if (globals.index == 0) {
        //_totalSeconds = 10;
        refreshTotalSeconds();
      } else {
        _totalSeconds = 5; //ned insert break time here
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

  void setupTimer() {
    _start = _totalSeconds;
    _current = _totalSeconds;
    minute = getMinute(_totalSeconds);
    seconds = getSeconds(_totalSeconds);
  }

  Widget inkWellButton(context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: globals.bgColor[globals.index]),
    );
    return GestureDetector(
      onLongPressUp: () {
        onFinished();
        try {
          timerObj.cancel();
        } catch (err) {
          print(err.toString());
        }
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Colors.white54,
          onTap: () {
            if (globals.isRunning == false) {
              //_showNotification();
              refreshTotalSeconds();
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
          child: Container(
            height: height,
            width: width,
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              //mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                AnimatedContainer(
                  padding: firstTap
                      ? EdgeInsets.only(top: height * 0.3)
                      : EdgeInsets.only(top: height * 0.1),
                  duration: Duration(seconds: 2),
                  curve: Curves.easeInOut,
                  child: FittedBox(
                    child: topText(context),
                  ),
                ),
                //SizedBox(height: MediaQuery.of(context).size.height*0.2,),
                AnimatedContainer(
                  padding: firstTap
                      ? EdgeInsets.only(top: height * 0.3)
                      : EdgeInsets.only(top: height * 0.5),
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
        child: (globals.isRunning)
            ? Text(
                '${beautifyNumber(minute)} : ${beautifyNumber(seconds)}',
                style: TextStyle(
                  color: Theme.of(context).textSelectionColor,
                  fontSize: 78,
                ),
              )
            : Text(
                '${beautifyNumber(getMinute(globals.globalTimer))} : ${beautifyNumber(getSeconds(globals.globalTimer))}',
                style: TextStyle(
                  color: Theme.of(context).textSelectionColor,
                  fontSize: 78,
                ),
              ),

        //make a if statement with has hour to show hour
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

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AlertPage'),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('go back...'),
        ),
      ),
    );
  }
}
