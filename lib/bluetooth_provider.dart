import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:protapp/protogen_provider.dart';

class BluetoothProvider with ChangeNotifier {
  FlutterBlue flutterBlue = FlutterBlue.instance;

  List<ScanResult> _results = [ ];
  List<ScanResult> get results => _results;

  get isAvailable => flutterBlue.isAvailable;
  get isOn => flutterBlue.isOn;

  scan(Duration timeout) async {
    this._results = await flutterBlue.startScan(
        scanMode: ScanMode.lowPower,
        timeout: timeout,

        withServices: <Guid>[
          ProtogenProvider.SERVICE_GUID
        ]
    );

    notifyListeners();
  }
}