import 'package:flutter_blue/flutter_blue.dart';
import 'package:protapp/protocol/protogen.dart';

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