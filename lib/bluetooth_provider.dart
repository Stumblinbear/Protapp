import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

Guid protogenServiceGuid = Guid('7c3181f8-8ac4-46a7-bd16-1269646c70d1');

class BluetoothProvider with ChangeNotifier {
  FlutterBlue flutterBlue = FlutterBlue.instance;

  List<ScanResult> _results = [ ];
  List<ScanResult> get results => _results;

  BluetoothDevice _device;
  BluetoothDevice get device => _device;

  get isAvailable => flutterBlue.isAvailable;
  get isOn => flutterBlue.isOn;

  scan(Duration timeout) async {
    if (!await Permission.location.isGranted) {
      if (await Permission.location.isPermanentlyDenied) {
        openAppSettings();
      }

      await Permission.location.request();
    }

    this._results = await flutterBlue.startScan(
        scanMode: ScanMode.lowPower,
        timeout: timeout,

        withServices: <Guid>[
          protogenServiceGuid
        ]
    );

    notifyListeners();
  }

  connect(BluetoothDevice device) {
    device.connect();

    this._device = device;

    notifyListeners();
  }

  disconnect() {
    this._device.disconnect();

    this._device = null;

    notifyListeners();
  }
}