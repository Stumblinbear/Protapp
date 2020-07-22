import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class StartupRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StartupRouteState();
}

class _StartupRouteState extends State<StartupRoute> {
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
  }

  // Check permission status
  Widget _step0() {
    return FutureBuilder<bool>(
        future: Permission.location.isGranted,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!snapshot.data) {
                setState(() {
                  _currentStep = 1;
                });
              } else {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/scan");
              }
            });
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          return Align(alignment: Alignment.center, child: CircularProgressIndicator());
        });
  }

  // Notify of reasoning for permission
  Widget _step1() {
    return Align(
        alignment: Alignment.bottomLeft,
        child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            reverse: true,
            child: TypewriterAnimatedTextKit(
                isRepeatingAnimation: false,
                speed: Duration(milliseconds: 50),
                textStyle: TextStyle(fontSize: 16.0, fontFamily: "Monospace"),
                textAlign: TextAlign.start,
                alignment: AlignmentDirectional.topStart,
                text: [
                  [
                    "ProtOS v0.9.3",
                    "-----------------",
                    "",
                    "Booting up....................OK",
                    "Verifying checksum............OK",
                    "\n",
                    "Welcome, user.",
                    "",
                    "In order to locate Friendly Neighborhood Protogen, I need access to your "
                        "current location. Please accept the request when it appears."
                  ].join("\n"),
                ],
                onFinished: () async {
                  if (!await Permission.location.request().isGranted) {
                    setState(() {
                      _currentStep = 2;
                    });
                  } else {
                    setState(() {
                      _currentStep = 0;
                    });
                  }
                })));
  }

  // Notify of reasoning for permission
  Widget _step2() {
    return FutureBuilder<bool>(
        future: Permission.location.isPermanentlyDenied,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (!snapshot.data) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _currentStep = 0;
                });
              });
            } else {
              return Align(
                  alignment: Alignment.bottomLeft,
                  child: SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      reverse: true,
                      child: TypewriterAnimatedTextKit(
                          isRepeatingAnimation: false,
                          speed: Duration(milliseconds: 50),
                          textStyle: TextStyle(fontSize: 16.0, fontFamily: "Monospace"),
                          textAlign: TextAlign.start,
                          alignment: AlignmentDirectional.topStart,
                          text: [
                            [
                              "Fatal Error: Locate permission has been permanently denied. Opening "
                                  "application settings so you may rectify this problem."
                            ].join("\n"),
                          ],
                          onFinished: () async {
                            await openAppSettings();

                            setState(() {
                              _currentStep = 0;
                            });
                          })));
            }
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          return Align(alignment: Alignment.center, child: CircularProgressIndicator());
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: [
      _step0,
      _step1,
      _step2,
    ][_currentStep]()));
  }
}
