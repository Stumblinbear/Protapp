import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';

const GUID_PREFIX = '920706E0-0000-0000-';

class ProtogenProvider with ChangeNotifier {
  FlutterBlue flutterBlue = FlutterBlue.instance;

  List<Protogen> protogen = [];

  Protogen _active;

  Protogen get active => _active;

  scan(Duration timeout) async {
    this.protogen.clear();

    for(ScanResult result in await flutterBlue.startScan(
        scanMode: ScanMode.lowPower,
        timeout: timeout,

        withServices: <Guid>[
          Protogen.SERVICE_GUID
        ]
    )) {
      var protogen = Protogen(result.advertisementData.localName, result.device);

      await protogen.ping();

      this.protogen.add(protogen);
    }

    notifyListeners();
  }

  setActive(Protogen protogen) async {
    if(this._active == protogen) return;

    this._active = protogen;

    notifyListeners();
  }

  void generate() {
    this.protogen = [
      Protogen.generate(),
      Protogen.generate(),
      Protogen.generate(),
      Protogen.generate(),
      Protogen.generate(),
    ];

    notifyListeners();
  }
}

class Protogen with ChangeNotifier {
  static Guid SERVICE_GUID = Guid(GUID_PREFIX + '0000-000000000000');

  static Guid MANUFACTURER = Guid('00002a29-0000-1000-8000-00805f9b34fb');
  static Guid MODEL = Guid('00002a24-0000-1000-8000-00805f9b34fb');
  static Guid SOFTWARE_REV = Guid('00002a28-0000-1000-8000-00805f9b34fb');
  static Guid HARDWARE_REV = Guid('00002a26-0000-1000-8000-00805f9b34fb');

  BluetoothDevice _device;

  get device => _device;

  String _name;

  String get name => _name;

  String _manufacturer;

  String get manufacturer => _manufacturer;

  String _model;

  String get model => _model;

  int _softwareRevision;

  int get softwareRevision => _softwareRevision;

  int _hardwareRevision;

  int get hardwareRevision => _hardwareRevision;

  ProtogenBattery _battery;

  ProtogenBattery get battery => _battery;

  ProtogenScreens _screens;

  ProtogenScreens get screens => _screens;

  ProtogenEmotes _emotes;

  ProtogenEmotes get emotes => _emotes;

  Protogen(this._name, this._device);

  ping() async {
    await this._connect();

    await this.disconnect();

    notifyListeners();
  }

  _connect() async {
    if(this._device == null) return;

    this._device.requestMtu(512);

    for (var service in (await this._device.discoverServices())) {
      if (service.uuid == ProtogenBattery.GUID) {
        this._battery = ProtogenBattery(service.characteristics);
        continue;
      }

      if (service.uuid == SERVICE_GUID) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid == MANUFACTURER) {
            this._manufacturer = utf8.decode(await characteristic.read());
            continue;
          }

          if (characteristic.uuid == MODEL) {
            this._model = utf8.decode(await characteristic.read());
            continue;
          }

          if (characteristic.uuid == SOFTWARE_REV) {
            this._softwareRevision = (await characteristic.read())[0];
            continue;
          }

          if (characteristic.uuid == HARDWARE_REV) {
            this._hardwareRevision = (await characteristic.read())[0];
            continue;
          }

          if (characteristic.uuid == ProtogenScreens.GUID) {
            this._screens = ProtogenScreens(characteristic);
          } else if (characteristic.uuid == ProtogenEmotes.GUID) {
            this._emotes = ProtogenEmotes(characteristic);
          }
        }
      }
    }
  }

  _attach() async {
    if (this._device == null) return;

    this._battery.attach();
    this._screens.attach();
    this._emotes.attach();
  }

  _disconnect() async {
    if (this._device == null) return;

    await this._device.disconnect();

    notifyListeners();
  }

  connect() async {
    await this._connect();

    await this._attach();

    notifyListeners();
  }

  disconnect() async {
    await this._disconnect();

    notifyListeners();
  }

  static Protogen generate() {
    var random = Random();

    String name = "";

    for(int i = 0; i < random.nextInt(12); i++) name += ascii.decode([ random.nextInt(26) + 65 ]);
    
    var protogen = Protogen(name, null);

    protogen._manufacturer = "ACME Technologies";
    protogen._model = "Beta Model " + ascii.decode([ random.nextInt(26) + 65 ]);
    protogen._softwareRevision = random.nextInt(12) + 1;
    protogen._hardwareRevision = -1;

    return protogen;
  }
}

// The battery service is in the bluetooth spec, so it needs to be handled differently
class ProtogenBattery with ChangeNotifier {
  static Guid GUID = Guid('0000180F-0000-1000-8000-00805f9b34fb');

  static Guid LEVEL = Guid('00002A19-0000-1000-8000-00805f9b34fb');
  static Guid LEVEL_STATE = Guid('00002A1B-0000-1000-8000-00805f9b34fb');
  static Guid POWER_STATE = Guid('00002A1A-0000-1000-8000-00805f9b34fb');

  BluetoothCharacteristic _levelCharacteristic, _levelStateCharacteristic, _powerStateCharacteristic;

  int _level, _levelState, _powerState;

  get level => _level;

  get levelState => _levelState;

  get powerState => _powerState;

  ProtogenBattery(List<BluetoothCharacteristic> characteristics) {
    characteristics.forEach((characteristic) {
      if (characteristic.uuid == LEVEL) {
        this._levelCharacteristic = characteristic;
      } else if (characteristic.uuid == LEVEL_STATE) {
        this._levelStateCharacteristic = characteristic;
      } else if (characteristic.uuid == POWER_STATE) {
        this._powerStateCharacteristic = characteristic;
      }
    });
  }

  get isSupported => _level != null;

  void read() async {
    var values = await Future.wait([
      this._levelCharacteristic.read(),
      this._levelStateCharacteristic.read(),
      this._powerStateCharacteristic.read(),
    ]);

    this._level = values[0].first;
    this._levelState = values[0].first;
    this._powerState = values[0].first;

    notifyListeners();
  }

  void attach() {
    this._levelCharacteristic.setNotifyValue(true);
    this._levelStateCharacteristic.setNotifyValue(true);
    this._powerStateCharacteristic.setNotifyValue(true);

    this._levelCharacteristic.value.listen((event) {
      this._level = event.first;

      notifyListeners();
    });

    this._levelStateCharacteristic.value.listen((event) {
      this._levelState = event.first;

      notifyListeners();
    });

    this._powerStateCharacteristic.value.listen((event) {
      this._powerState = event.first;

      notifyListeners();
    });
  }
}

// Wraps out custom characteristics to handle Protogen data
abstract class ProtogenCharacteristic with ChangeNotifier {
  BluetoothCharacteristic characteristic;

  Map<Guid, BluetoothDescriptor> descriptors;

  ProtogenCharacteristic(this.characteristic) {
    if (this.characteristic != null) {
      this.characteristic.descriptors.forEach((descriptor) {
        this.descriptors[descriptor.uuid] = descriptor;
      });
    }
  }

  get isSupported => characteristic != null;

  void read();

  void attach();
}

class ProtogenScreens extends ProtogenCharacteristic {
  static Guid GUID = Guid(GUID_PREFIX + '0002-000000000000');

  ProtogenScreens(characteristic) : super(characteristic);

  @override
  void attach() {
    // TODO: implement attach
  }

  @override
  void read() {
    // TODO: implement read
  }
}

class ProtogenEmotes extends ProtogenCharacteristic {
  static Guid GUID = Guid(GUID_PREFIX + '0003-000000000000');

  ProtogenEmotes(characteristic) : super(characteristic);

  @override
  void attach() {
    // TODO: implement attach
  }

  @override
  void read() {
    // TODO: implement read
  }
}
