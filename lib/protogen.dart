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

  static Guid UPLOAD = Guid(GUID_PREFIX + 'FFFF-FFFFFFFFFFF0');
  static Guid UPLOAD_TYPE = Guid(GUID_PREFIX + 'FFFF-FFFFFFFFFFF1');
  static Guid UPLOAD_NAME = Guid(GUID_PREFIX + 'FFFF-FFFFFFFFFFF2');
  static Guid UPLOAD_CHECKSUM = Guid(GUID_PREFIX + 'FFFF-FFFFFFFFFFFF');

  BluetoothDevice _device;

  get device => _device;

  String _name;

  String get name => _name;

  ProtogenInfo _info;

  ProtogenInfo get info => _info;

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
        this._battery = ProtogenBattery(service);
        continue;
      }

      if (service.uuid == SERVICE_GUID) {
        this._info = ProtogenInfo(service);

        for(var subService in service.includedServices) {
          if (subService.uuid == ProtogenScreens.GUID) {
            this._screens = ProtogenScreens(subService);
          } else if (subService.uuid == ProtogenEmotes.GUID) {
            this._emotes = ProtogenEmotes(subService);
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

    protogen._info = ProtogenInfo.generate();

    return protogen;
  }
}

// Wraps out custom characteristics to handle Protogen data
abstract class ProtogenService with ChangeNotifier {
  BluetoothService service;

  Map<Guid, BluetoothCharacteristic> characteristics;

  ProtogenService(this.service) {
    if (this.service != null) {
      this.service.characteristics.forEach((characteristic) {
        this.characteristics[characteristic.uuid] = characteristic;
      });
    }
  }

  get isSupported => service != null;

  void read();

  void attach();
}

class ProtogenInfo extends ProtogenService {
  static Guid MANUFACTURER = Guid(GUID_PREFIX + '-0000-000000000001');
  static Guid MODEL = Guid(GUID_PREFIX + '-0000-000000000002');
  static Guid MANUFACTURE_DATE = Guid(GUID_PREFIX + '-0000-000000000003');

  static Guid SOFTWARE_REV = Guid(GUID_PREFIX + '-0000-000000000004');
  static Guid HARDWARE_REV = Guid(GUID_PREFIX + '-0000-000000000004');

  static List<Guid> ALL_GUIDS = [ MANUFACTURER, MODEL, MANUFACTURE_DATE, SOFTWARE_REV, HARDWARE_REV ];

  String _manufacturer, _model, _manufactureDate;

  int _softwareRevision, _hardwareRevision;

  String get manufacturer => _manufacturer;

  String get manufactureDate => _manufactureDate;

  String get model => _model;

  int get softwareRevision => _softwareRevision;

  int get hardwareRevision => _hardwareRevision;

  ProtogenInfo(BluetoothService service) : super(service);

  @override
  void read() async {
    if(!isSupported) {
      throw UnsupportedError("Battery service not supported.");
    }

    var values = await Future.wait(ALL_GUIDS.map((guid) => this.characteristics[guid].read()));

    this._manufacturer = utf8.decode(values[0]);
    this._model = utf8.decode(values[1]);
    this._manufactureDate = utf8.decode(values[2]);
    this._softwareRevision = values[3].first;
    this._hardwareRevision = values[4].first;

    notifyListeners();
  }

  @override
  void attach() async {
    throw UnsupportedError("Battery service not supported.");
  }

  static ProtogenInfo generate() {
    var random = Random();

    ProtogenInfo info = ProtogenInfo(null);

    info._manufacturer = "ACME Technologies";
    info._model = "Beta Model " + ascii.decode([ random.nextInt(26) + 65 ]);
    info._manufactureDate = "September 11, 2001";

    info._softwareRevision = random.nextInt(12) + 1;
    info._hardwareRevision = -1;

    return info;
  }
}

// The battery service is in the bluetooth spec
class ProtogenBattery extends ProtogenService {
  static Guid GUID = Guid('0000180F-0000-1000-8000-00805f9b34fb');

  static Guid LEVEL = Guid('00002A19-0000-1000-8000-00805f9b34fb');
  static Guid LEVEL_STATE = Guid('00002A1B-0000-1000-8000-00805f9b34fb');
  static Guid POWER_STATE = Guid('00002A1A-0000-1000-8000-00805f9b34fb');

  static List<Guid> ALL_GUIDS = [ LEVEL, LEVEL_STATE, POWER_STATE ];

  int _level, _levelState, _powerState;

  get level => _level;

  get levelState => _levelState;

  get powerState => _powerState;

  ProtogenBattery(BluetoothService service) : super(service);

  @override
  void read() async {
    if(!isSupported) {
      throw UnsupportedError("Battery service not supported.");
    }

    var values = await Future.wait(ALL_GUIDS.map((guid) => this.characteristics[guid].read()));

    this._level = values[0].first;
    this._levelState = values[1].first;
    this._powerState = values[2].first;

    notifyListeners();
  }

  @override
  void attach() async {
    if(!isSupported) {
      throw UnsupportedError("Battery service not supported.");
    }

    await Future.wait(ALL_GUIDS.map((guid) => this.characteristics[guid].setNotifyValue(true)));

    this.characteristics[LEVEL].value.listen((event) {
      this._level = event.first;

      notifyListeners();
    });

    this.characteristics[LEVEL].value.listen((event) {
      this._levelState = event.first;

      notifyListeners();
    });

    this.characteristics[LEVEL].value.listen((event) {
      this._powerState = event.first;

      notifyListeners();
    });
  }
}

class ProtogenScreens extends ProtogenService {
  static Guid GUID = Guid(GUID_PREFIX + '0002-000000000000');

  ProtogenScreens(BluetoothService service) : super(service);

  @override
  void attach() async {
    if(!isSupported) {
      throw UnsupportedError("Screen service not supported.");
    }

    // TODO: implement attach
  }

  @override
  void read() async {
    if(!isSupported) {
      throw UnsupportedError("Screen service not supported.");
    }

    // TODO: implement read
  }
}

class ProtogenEmotes extends ProtogenService {
  static Guid GUID = Guid(GUID_PREFIX + '0003-000000000000');

  ProtogenEmotes(BluetoothService characteristic) : super(characteristic);

  @override
  void attach() async {
    if(!isSupported) {
      throw UnsupportedError("Emote service not supported.");
    }

    // TODO: implement attach
  }

  @override
  void read() async {
    if(!isSupported) {
      throw UnsupportedError("Emote service not supported.");
    }

    // TODO: implement read
  }
}
