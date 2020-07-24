import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
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

  BluetoothDevice _device;

  int _packetSize;

  get device => _device;

  String _name;

  String get name => _name;

  ProtogenInfo _info;

  ProtogenInfo get info => _info;

  ProtogenBattery _battery;

  ProtogenBattery get battery => _battery;

  ProtogenScreens _screens;

  ProtogenScreens get screens => _screens;

  ProtogenActions _actions;

  ProtogenActions get actions => _actions;

  Protogen(this._name, this._device);

  ping() async {
    await this._connect();

    await this.disconnect();

    notifyListeners();
  }

  _connect() async {
    if(this._device == null) return;

    // Update the current MTU if it changes
    this._device.mtu.listen((mtu) {
      _packetSize = mtu - 3; // 3 bytes of header information
    });

    await this._device.requestMtu(512);

    for (var service in (await this._device.discoverServices())) {
      if (service.uuid == ProtogenBattery.GUID) {
        this._battery = ProtogenBattery(this, service);
        continue;
      }

      if (service.uuid == SERVICE_GUID) {
        this._info = ProtogenInfo(this, service);

        for(var subService in service.includedServices) {
          if (subService.uuid == ProtogenScreens.GUID) {
            this._screens = ProtogenScreens(this, subService);
          } else if (subService.uuid == ProtogenActions.GUID) {
            this._actions = ProtogenActions(this, subService);
          }
        }
      }
    }
  }

  _disconnect() async {
    if (this._device == null) return;

    await this._device.disconnect();

    notifyListeners();
  }

  connect() async {
    await this._connect();

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

    protogen._info = ProtogenInfo.generate(protogen);

    return protogen;
  }
}

// Wraps our custom characteristics
abstract class ProtogenService with ChangeNotifier {
  Protogen protogen;

  BluetoothService service;

  Map<Guid, BluetoothCharacteristic> characteristics;

  ProtogenService(this.protogen, this.service) {
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

abstract class ProtogenDataService extends ProtogenService {
  static Guid STATE = Guid(GUID_PREFIX + 'FFFF-FFFFFFFFFFFD');
  static Guid PART = Guid(GUID_PREFIX + 'FFFF-FFFFFFFFFFFE');
  static Guid CHECKSUM = Guid(GUID_PREFIX + 'FFFF-FFFFFFFFFFFF');

  List<int> _checksum;

  ProtogenDataService(Protogen protogen, BluetoothService service) : super(protogen, service) {
    characteristics[CHECKSUM].setNotifyValue(true);

    characteristics[CHECKSUM].value.listen((data) {
      _checksum = data;
    });
  }

  void send(List<int> data, { Function(List<int>) onResponse }) async {
    // Tell the device we want to send data
    characteristics[STATE].write([ 1 ], withoutResponse: false);

    // Update the checksum
    characteristics[CHECKSUM].write(md5.convert(data).bytes.getRange(0, min(32, protogen._packetSize)), withoutResponse: false);

    // Split up the data into the MTU size and send it
    for(int i = 0; i < data.length; i++)
      await characteristics[PART].write(data.getRange(i, min(i + protogen._packetSize, data.length)), withoutResponse: false);

    // Tell the device we're done sending data
    characteristics[STATE].write([ 0 ], withoutResponse: false);

    // If we've defined onResponse, then we're expecting a return value
    if(onResponse != null) {
      // Once we've written the data, listen in the other direction
      await characteristics[PART].setNotifyValue(true);
      await characteristics[STATE].setNotifyValue(true);

      List<int> response = List<int>();

      characteristics[PART].value.listen((data) {
        response += data;
      });

      characteristics[STATE].value.listen((data) async {
        if (data.first == 1) return;

        // Something happened (other than the "begun transfer" notification). Stop listening.
        await characteristics[STATE].setNotifyValue(false);
        await characteristics[PART].setNotifyValue(false);

        if (data.first == -1) {
          print("Protogen received bad data, resending request.");

          // Resend the request
          send(data, onResponse: onResponse);
        } else if (data.first == 0) {
          if(_checksum == md5.convert(response).bytes.getRange(0, min(32, protogen._packetSize))) {
            print("Received bad data, resending request.");

            // Resend the request
            send(data, onResponse: onResponse);

            return;
          }

          onResponse(response);
        }
      });
    }
  }
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

  ProtogenInfo(Protogen protogen, BluetoothService service) : super(protogen, service);

  @override
  void read() async {
    if(!isSupported) {
      throw UnsupportedError("Battery service not supported.");
    }

    var values = await Future.wait(ALL_GUIDS.map((guid) => this.characteristics[guid].read()));

    this._manufacturer = utf8.decode(values[0]);
    this._model = utf8.decode(values[1]);
    this._manufactureDate = utf8.decode(values[2]);
    // Uint8List(4)..buffer.asByteData().setInt16(0, value, Endian.big)
    this._softwareRevision = Uint8List.fromList(values[3]).buffer.asByteData().getUint16(0);
    this._hardwareRevision = Uint8List.fromList(values[4]).buffer.asByteData().getUint16(0);

    notifyListeners();
  }

  @override
  void attach() async {
    throw UnsupportedError("Battery service not supported.");
  }

  static ProtogenInfo generate(Protogen protogen) {
    var random = Random();

    ProtogenInfo info = ProtogenInfo(protogen, null);

    info._manufacturer = "ACME Technologies";
    info._model = "Beta Model " + ascii.decode([ random.nextInt(26) + 65 ]);
    info._manufactureDate = "September 11, 2001";

    info._softwareRevision = random.nextInt(12) + 1;
    info._hardwareRevision = 1;

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

  ProtogenBattery(Protogen protogen, BluetoothService service) : super(protogen, service);

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

class ProtogenScreens extends ProtogenDataService {
  static Guid GUID = Guid(GUID_PREFIX + '0002-000000000000');

  ProtogenScreens(Protogen protogen, BluetoothService service) : super(protogen, service);

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

class ProtogenActions extends ProtogenDataService {
  static Guid GUID = Guid(GUID_PREFIX + '0003-000000000000');

  ProtogenActions(Protogen protogen, BluetoothService service) : super(protogen, service);

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

class ProtogenAction {
  String name;
  String icon;

  ProtogenAction(this.name, { this.icon });
}