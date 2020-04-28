import 'package:flutter/material.dart';
import 'package:simple_pomodoro/global.dart' as globals;
import 'package:simple_pomodoro/skeleton.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:simple_pomodoro/settings.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Duration animationDuration = Duration(milliseconds: 300);
  final Duration delay = Duration(milliseconds: 300);
  GlobalKey rectGetterKey = RectGetter.createGlobalKey();
  Rect rect;
  bool settingPage = false;
  int rebuildCounter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          backgroundColor(),
          StatefulBuilder(builder: (context, StateSetter setState) {
            print("global timer in the rebuild ${globals.globalTimer}" );
            return Stack(
              children: <Widget>[
                Skeleton(switchBGColor),
                settingBtn(() {
                  setState(() {
                    rebuildCounter++;
                    print(rebuildCounter);
                  });
                }),
              ],
            );
          }),
          _ripple(),
        ],
      ),
    );
  }

  void _onTap(incrementCounter) async {
    setState(() => rect = RectGetter.getRectFromKey(rectGetterKey));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() =>
          rect = rect.inflate(1.3 * MediaQuery.of(context).size.longestSide));
      Future.delayed(
          animationDuration + delay, () => _goToNextPage(incrementCounter));
    });
  }

  void _goToNextPage(incrementCounter) {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (context) => Settings(incrementCounter),
        ))
        .then((_) => setState(() => rect = null));
  }

  //it is here because i want to trigger the setstate in home.dart not skeleton.dart
  void switchBGColor() {
    setState(() {
      if (globals.index == 0) {
        globals.index = 1;
      } else {
        globals.index = 0;
      }
    });
  }

  Widget backgroundColor() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 700),
      curve: Curves.fastOutSlowIn,
      color: globals.bgColor[globals.index],
      child: Container(),
    );
  }

  Widget settingBtn(incrementCounter) {
    return RectGetter(
      key: rectGetterKey,
      child: Positioned(
        top: MediaQuery.of(context).padding.top,
        right: 0,
        child: FloatingActionButton(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            child: Icon(Icons.settings),
            onPressed: () => _onTap(incrementCounter)),
      ),
    );
  }

  Widget _ripple() {
    if (rect == null) {
      return Container();
    }
    return AnimatedPositioned(
      duration: animationDuration,
      left: rect.left,
      right: MediaQuery.of(context).size.width - rect.right,
      top: rect.top,
      bottom: MediaQuery.of(context).size.height - rect.bottom,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
      ),
    );
  }
}
