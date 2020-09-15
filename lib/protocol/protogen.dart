import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:protapp/protocol/screens.dart';

import 'actions.dart';
import 'battery.dart';
import 'info.dart';

const GUID_PREFIX = '920706E0-0000-0000-';

class ProtogenProvider with ChangeNotifier {
  FlutterBlue flutterBlue = FlutterBlue.instance;

  List<Protogen> protogen = [];

  Protogen _active;

  Protogen get active => _active;

  scan(Duration timeout) async {
    this.protogen.clear();

    print('Scanning for nearby Protogen...');

    if(await flutterBlue.isScanning.first)
      await flutterBlue.stopScan();

    for(ScanResult result in await flutterBlue.startScan(
        scanMode: ScanMode.lowPower,
        timeout: timeout,

        withServices: <Guid>[
          Protogen.SERVICE_GUID
        ]
    )) {
      print(result);

      var protogen = Protogen(result.advertisementData.localName, result.device);

      await protogen.ping();

      print(protogen);

      this.protogen.add(protogen);

      notifyListeners();
    }

    print('Done scanning.');
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

    // Fetch basic information if it exists
    if(this.info != null)
      await this.info.read();

    await this.disconnect();

    notifyListeners();
  }

  _connect() async {
    if(this._device == null) return;

    await this._device.connect();

    // Update the current MTU if it changes
    this._device.mtu.listen((mtu) {
      _packetSize = mtu - 3; // 3 bytes of header information
    });

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

    await this._device.requestMtu(512);

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
    protogen._actions = ProtogenActions.generate(protogen);

    return protogen;
  }
}

// Wraps our custom characteristics
abstract class ProtogenService with ChangeNotifier {
  Protogen protogen;

  BluetoothService service;

  Map<Guid, BluetoothCharacteristic> characteristics = Map();

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

  Future<String> readString(Guid uuid) async {
    return utf8.decode(await this.characteristics[uuid].read());
  }

  writeString(Guid uuid, String text) async {
    await this.characteristics[uuid].write(utf8.encode(text));
  }

  Future<int> readUint8(Guid uuid) async {
    return (await this.characteristics[uuid].read())[0];
  }

  writeUint8(Guid uuid, Uint8 byte) async {
    await this.characteristics[uuid].write(List(byte as int));
  }

  Future<int> readUint16(Guid uuid) async {
    return Uint8List.fromList(await this.characteristics[uuid].read()).buffer.asByteData().getUint16(0, Endian.little);
  }

  writeUint16(Guid uuid, Uint16 short) async {
    await this.characteristics[uuid].write(Uint8List(2)..buffer.asByteData().setInt16(0, short as int, Endian.little));
  }

  Future<int> readUint32(Guid uuid) async {
    return Uint8List.fromList(await this.characteristics[uuid].read()).buffer.asByteData().getUint32(0, Endian.little);
  }

  writeUint32(Guid uuid, Uint32 integer) async {
    await this.characteristics[uuid].write(Uint8List(4)..buffer.asByteData().setInt32(0, integer as int, Endian.little));
  }
}

abstract class ProtogenDataService extends ProtogenService {
  static Guid STATE = Guid(GUID_PREFIX + 'FFFF-FFFFFFFFFFFD');
  static Guid PART = Guid(GUID_PREFIX + 'FFFF-FFFFFFFFFFFE');
  static Guid CHECKSUM = Guid(GUID_PREFIX + 'FFFF-FFFFFFFFFFFF');

  List<int> _checksum;

  ProtogenDataService(Protogen protogen, BluetoothService service) : super(protogen, service) {
    if(characteristics.containsKey(CHECKSUM)) {
      characteristics[CHECKSUM].setNotifyValue(true);

      characteristics[CHECKSUM].value.listen((data) {
        _checksum = data;
      });
    }
  }

  void send(List<int> data, { Function(List<int>) onResponse }) async {
    // Tell the device we want to send data
    characteristics[STATE].write([ 1 ], withoutResponse: false);

    // Update the checksum
    characteristics[CHECKSUM].write(md5.convert(data).bytes.getRange(0, min(32, protogen._packetSize)), withoutResponse: false);

    // Split up the data into the MTU size and send it
    for(int i = 0; i < data.length; i += protogen._packetSize)
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
