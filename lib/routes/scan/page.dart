import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:protapp/protogen.dart';
import 'package:provider/provider.dart';

class ScanRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScanRouteState();
}

class _ScanRouteState extends State<ScanRoute> {
  bool _timedOut = false;

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((context) => initScan());
  }

  initScan() async {
    // Initiate a scan for Protogen.
    try {
      await context.read<ProtogenProvider>().scan(Duration(seconds: 20));
    } catch(e) {
      if(e is PlatformException) {
        print("Bluetooth not supported, therefore this is likely a development device. Generating test data.");

        Future.delayed(Duration(seconds: 20), () => context.read<ProtogenProvider>().generate());

        return;
      }else if(e.toString() == 'Error starting scan.') {
        return;
      }

      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    if(this._timedOut) {
      return SafeArea(
          child: Scaffold(
              body: _buildTimedOut()
          )
      );
    }

    if(context.watch<ProtogenProvider>().protogen.length > 0) {
      return SafeArea(
          child: Scaffold(
            body: _buildBluetoothList()
          )
      );
    }

    return SafeArea(
        child: Scaffold(
            body: _buildWaitAnimation()
        )
    );
  }

  Widget _buildWaitAnimation() {
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
                  "ProtoSense v0.2.1",
                  "-----------------",
                  "",
                  "Booting up....................OK",
                  "Verifying checksum............OK",
                  "\n",
                  "Welcome, user. Please wait......",
                  "",
                  "Initializing system...........OK",
                  "Initializing antenna..........OK",
                  "Building service net..........OK",
                  "Preparing payload.............OK",
                  "\n",
                  "Please ensure your Friendly Neighborhood Protogen is willing and accepting connections."
                      "\n",
                  "Searching" + "." * 500 + "FAIL"
                ].join("\n"),
              ],
              onFinished: () {
                Future.delayed(const Duration(milliseconds: 1000), () {
                  setState(() {
                    _timedOut = true;
                  });
                });
              },
            )));
  }

  Widget _buildTimedOut() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Timed out. Unable to locate Protogen nearby.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0, fontFamily: "Monospace"),
        ),
        Padding(padding: EdgeInsets.all(16), child: Divider()),
        Container(
          width: double.infinity,
          child: FlatButton(
            onPressed: () {
              setState(() {
                _timedOut = false;

                context.read<ProtogenProvider>().scan(Duration(seconds: 30));
              });
            },
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                "Try Again",
                style: TextStyle(fontSize: 20.0, fontFamily: "Monospace"),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildBluetoothList() {
    List<Widget> deviceList = [];

    context.watch<ProtogenProvider>().protogen.forEach((protogen) => {
      deviceList.add(Container(
        width: double.infinity,
        child: FlatButton(
          onPressed: () {
            context.read<ProtogenProvider>().setActive(protogen);

            Navigator.pop(context);
            Navigator.pushNamed(context, "/home");
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    protogen.name,
                    style: TextStyle(fontSize: 20.0, fontFamily: "Monospace"),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    protogen.manufacturer + ' ' + protogen.model,
                    style: TextStyle(fontSize: 16.0, fontFamily: "Monospace"),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'rev. ' + protogen.softwareRevision.toString() + ' / ' + protogen.hardwareRevision.toString(),
                    style: TextStyle(fontSize: 16.0, fontFamily: "Monospace"),
                  ),
                ),
              ],
            )
          )
        ),
      ))
    });

    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(32),
          child: Text(
            "${context.watch<ProtogenProvider>().protogen.length} Protogen successfully found:",
            style: TextStyle(fontSize: 16.0, fontFamily: "Monospace"),
          ),
        ),
        Divider(color: Colors.white),
        Expanded(
          child: SingleChildScrollView(
            child: Column(children: deviceList),
          ),
        )
      ],
    );
  }
}
