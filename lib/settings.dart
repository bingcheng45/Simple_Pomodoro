import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_pomodoro/global.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Duration workTimer;
  Duration workTimerTemp;
  final hKeyW = 'hour_key_work';
  final mKeyW = 'minute_key_work';
  int wHour, wMinute;
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    _getWorkTimer().then((list) {
      setState(() {
        wHour = list[0];
        wMinute = list[1];
        workTimer = Duration(hours: wHour, minutes: wMinute);
      });
    });
  }

  void _setWorkTimer(hour, minutes) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(hKeyW, hour);
    prefs.setInt(mKeyW, minutes);
  }

  Future<List<int>> _getWorkTimer() async {
    final prefs = await SharedPreferences.getInstance();
    int hour = prefs.getInt(hKeyW) ?? 0;
    int minute = prefs.getInt(mKeyW) ?? 25;
    return [hour, minute];
  }

  Widget timerPicker(context) {
    return AlertDialog(
      title: Text("Edit Timer"),
      backgroundColor: Colors.white,
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CupertinoTimerPicker(
                initialTimerDuration: Duration(hours: wHour, minutes: wMinute),
                minuteInterval: 5,
                backgroundColor: Colors.blue,
                mode: CupertinoTimerPickerMode.hm,
                onTimerDurationChanged: (value) {
                  setState(() {
                    workTimerTemp = value;
                    if (value.inHours == 0 && (value.inMinutes % 60) == 0) {
                      _opacity = 1;
                    } else {
                      _opacity = 0;
                    }
                  });
                },
              ),
              Opacity(
                opacity: _opacity,
                child: Container(
                  padding: EdgeInsets.only(top: 10, bottom: 0),
                  child: Text(
                    'You cannot set timer to 0 hours and 0 minute!',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Cancel"),
          onPressed: () {
            workTimerTemp = workTimer;
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text("Save"),
          onPressed: () {
            saveWorkTime(context);
          },
        ),
      ],
    );
  }

  void saveWorkTime(context) {
    setState(() {
      if (_opacity == 1) {
        //do nothing
      } else {
        workTimer = workTimerTemp;
        wHour = workTimer.inHours;
        wMinute = workTimer.inMinutes % 60;
        _setWorkTimer(wHour, wMinute);
        Navigator.of(context).pop();
      }
    });
  }

  Widget editWorkTimer() {
    return ListTile(
      title: Text(
        "Curent Duration:",
        style: TextStyle(
          fontSize: 20,
        ),
      ),
      trailing: FittedBox(
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
            children: <TextSpan>[
              TextSpan(
                text: '$wHour ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: 'hour '),
              TextSpan(
                text: '$wMinute ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: 'minute '),
            ],
          ),
        ),
      ),
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return timerPicker(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text(
          "Settings",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: globals.bgColor[globals.index],
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(
              'Pomodoro Work duration',
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          editWorkTimer(),
        ],
      ),
    );
  }
}
