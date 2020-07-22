import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';

const GUID_PREFIX = '920706E0-0000-0000-';

class ProtogenProvider with ChangeNotifier {
  static Guid SERVICE_GUID = Guid(GUID_PREFIX + '0000-00000000');

  BluetoothDevice _device;

  // Holds all available services
  Map<Guid, BluetoothService> _services;

  // Holds the characteristics from the Protogen service
  Map<Guid, BluetoothCharacteristic> _characteristics;

  get device => _device;

  get battery async => ProtogenBattery(this._services[ProtogenBattery.GUID].characteristics);

  get screens async => ProtogenScreens(this._characteristics[ProtogenScreens.GUID]);

  get emotes async => ProtogenEmotes(this._characteristics[ProtogenEmotes.GUID]);

  connect(BluetoothDevice device) async {
    await device.connect();

    this._device = device;

    this._device.requestMtu(512);

    (await device.discoverServices()).forEach((service) {
      this._services[service.uuid] = service;
    });

    this._services[SERVICE_GUID].characteristics.forEach((characteristic) {
      this._characteristics[characteristic.uuid] = characteristic;
    });

    notifyListeners();
  }

  disconnect() async {
    if(this._device == null) return;

    await this._device.disconnect();

    this._device = null;

    notifyListeners();
  }
}


// The battery service is in the bluetooth spec, so it needs to be handled differently
class ProtogenBattery {
  static Guid GUID = Guid('0000180F-0000-1000-8000-00805f9b34fb');

  static Guid LEVEL = Guid('00002A19-0000-1000-8000-00805f9b34fb');
  static Guid LEVEL_STATE = Guid('00002A1B-0000-1000-8000-00805f9b34fb');
  static Guid POWER_STATE = Guid('00002A1A-0000-1000-8000-00805f9b34fb');

  Map<Guid, BluetoothCharacteristic> characteristics;

  ProtogenBattery(characteristics);

  get isSupported => characteristics != null;

  get level async => await characteristics[LEVEL].read();
}


// Wraps out custom characteristics to handle Protogen data
class ProtogenCharacteristic {
  BluetoothCharacteristic characteristic;

  Map<Guid, BluetoothDescriptor> descriptors;

  ProtogenCharacteristic(this.characteristic) {
    if(this.characteristic != null) {
      this.characteristic.descriptors.forEach((descriptor) {
        this.descriptors[descriptor.uuid] = descriptor;
      });
    }
  }

  get isSupported => characteristic != null;
}

class ProtogenInfo extends ProtogenCharacteristic {
  static Guid GUID = Guid(GUID_PREFIX + '0001-00000000');

  static Guid MANUFACTURER = Guid('00002a29-0000-1000-8000-00805f9b34fb');
  static Guid MODEL = Guid('00002a24-0000-1000-8000-00805f9b34fb');
  static Guid SOFTWARE_REV = Guid('00002a28-0000-1000-8000-00805f9b34fb');
  static Guid HARDWARE_REV = Guid('00002a26-0000-1000-8000-00805f9b34fb');

  ProtogenInfo(characteristic) : super(characteristic);
}

class ProtogenScreens extends ProtogenCharacteristic {
  static Guid GUID = Guid(GUID_PREFIX + '0002-00000000');

  ProtogenScreens(characteristic) : super(characteristic);
}

class ProtogenEmotes extends ProtogenCharacteristic {
  static Guid GUID = Guid(GUID_PREFIX + '0003-00000000');

  ProtogenEmotes(characteristic) : super(characteristic);
}