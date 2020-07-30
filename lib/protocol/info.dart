import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:protapp/protocol/protogen.dart';

class ProtogenInfo extends ProtogenService {
  static Guid MANUFACTURER = Guid(GUID_PREFIX + '-0000-000000000001');
  static Guid MODEL = Guid(GUID_PREFIX + '-0000-000000000002');
  static Guid MANUFACTURE_DATE = Guid(GUID_PREFIX + '-0000-000000000003');

  static Guid SOFTWARE_REV = Guid(GUID_PREFIX + '-0000-000000000004');
  static Guid HARDWARE_REV = Guid(GUID_PREFIX + '-0000-000000000005');

  static List<Guid> ALL_GUIDS = [ MANUFACTURER, MODEL, MANUFACTURE_DATE, SOFTWARE_REV, HARDWARE_REV ];

  String _manufacturer, _model = "Unknown", _manufactureDate;

  int _softwareRevision = -1, _hardwareRevision = -1;

  String get manufacturer => _manufacturer != null ? _manufacturer : "Unknown";

  String get manufactureDate => _manufactureDate != null ? _manufactureDate : "N/A";

  String get model => _model != null ? _model : "N/A";

  int get softwareRevision => _softwareRevision;

  int get hardwareRevision => _hardwareRevision;

  ProtogenInfo(Protogen protogen, BluetoothService service) : super(protogen, service);

  @override
  void read() async {
    if(!isSupported) {
      throw UnsupportedError("Battery service not supported.");
    }

    this._manufacturer = await this.readString(MANUFACTURER);
    this._model = await this.readString(MODEL);
    this._manufactureDate = await this.readString(MANUFACTURE_DATE);
    this._softwareRevision = await this.readUint16(SOFTWARE_REV);
    this._hardwareRevision = await this.readUint16(HARDWARE_REV);

    notifyListeners();
  }

  @override
  void attach() async {
    throw UnsupportedError("Info service characteristics cannot be attached.");
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