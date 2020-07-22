import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:protapp/bluetooth_provider.dart';
import 'package:protapp/protogen_provider.dart';
import 'package:provider/provider.dart';

class ScanRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScanRouteState();
}

class _ScanRouteState extends State<ScanRoute> {
  BluetoothProvider bluetoothProvider = new BluetoothProvider();

  bool _timedOut = false;

  @override
  initState() {
    super.initState();

    // Clear the active Protogen connection.
    context.read<ProtogenProvider>().disconnect();

    initScan();
  }

  initScan() async {
    // Initiate a scan for Protogen.
    try {
      await bluetoothProvider.scan(Duration(seconds: 30));
    } catch(e) {
      if(e is PlatformException) {
        print("Bluetooth not supported, therefore this is likely a development device. Dumping to home screen with testing data.");

        Navigator.pop(context);
        Navigator.pushNamed(context, "/home");

        return;
      }

      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    if(context.watch<ProtogenProvider>().device != null) {
      Navigator.pop(context);
      Navigator.pushNamed(context, "/home");
    }

    if(this._timedOut) {
      return SafeArea(
          child: Scaffold(
              body: _buildTimedOut()
          )
      );
    }

    if(bluetoothProvider.results.length > 0) {
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

                bluetoothProvider.scan(Duration(seconds: 30));
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
        ),
        Container(
          width: double.infinity,
          child: FlatButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/home");
            },
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                "Dev Skip",
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

    bluetoothProvider.results.forEach((result) => {
      deviceList.add(Container(
        width: double.infinity,
        child: FlatButton(
          onPressed: () {
            context.read<ProtogenProvider>().connect(result.device);
          },
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              result.advertisementData.localName,
              style: TextStyle(fontSize: 20.0, fontFamily: "Monospace"),
            ),
          ),
        ),
      ))
    });

    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(32),
          child: Text(
            "${bluetoothProvider.results.length} Protogen successfully found:",
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
