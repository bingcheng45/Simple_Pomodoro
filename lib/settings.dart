import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_pomodoro/global.dart' as globals;
import 'package:preferences/preferences.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  var value = "";
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
          SwitchListTile(
            value: false,
            title: Text("This is a SwitchPreference"),
            onChanged: (value) {},
          ),
          PreferenceDialogLink(
            'Edit description',
            dialog: PreferenceDialog(
              [
                CupertinoTimerPicker(
                  initialTimerDuration: Duration(minutes: 25),
                  minuteInterval: 5,
                  mode: CupertinoTimerPickerMode.hm,
                  onTimerDurationChanged: (value) {
                    setState(() {
                      this.value = value.toString();
                      print(this.value);
                    });
                  },
                ),
              ],
              title: 'Edit description',
              cancelText: 'Cancel',
              submitText: 'Save',
              onlySaveOnSubmit: true,
            ),
            onPop: () => setState(() {}),
          ),
          SwitchListTile(
            value: false,
            title: Text("This is a SwitchPreference"),
            onChanged: (value) {
              value = true;
            },
          ),
          PreferenceTitle('Pomodoro Work duration'),
          DropdownPreference(
            'Start Page',
            'start_page',
            defaultVal: 'Timeline',
            values: ['Posts', 'Timeline', 'Private Messages'],
          ),
          SwitchPreference("title", "localKey"),
        ],
      ),
    );
  }
}
