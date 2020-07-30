import 'package:flutter_blue/flutter_blue.dart';
import 'package:protapp/protocol/protogen.dart';

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

    var values = await Future.wait(ALL_GUIDS.map((guid) =>
        this.characteristics.containsKey(guid) ? this.characteristics[guid].read() : null));

    this._level = values[0] != null ? values[0].first : 0;
    this._levelState = values[1] != null ? values[1].first : 0;
    this._powerState = values[2] != null ? values[2].first : 0;

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