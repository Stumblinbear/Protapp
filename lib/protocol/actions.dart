import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:protapp/protocol/protogen.dart';

class ProtogenTaskSettings {
  static var boolean = ProtogenTaskSettingType<void>(
    getWidget: (setting) => Text(setting.name)
  );

  /// List<int> config is the minimum and maximum values
  static var integer = ProtogenTaskSettingType<List<int>>(
      decode: (buffer) => [ buffer.getInt32(0, Endian.little), buffer.getInt32(4, Endian.little), ],
      getWidget: (setting) => Text(setting.name)
  );

  /// List<int> config is the minimum and maximum length
  static var string = ProtogenTaskSettingType<List<int>>(
      decode: (buffer) => [ buffer.getUint32(0, Endian.little), buffer.getUint32(4, Endian.little), ],
      getWidget: (setting) => Text(setting.name)
  );

  /// String config is the mime type of the requested file
  static var fileInput = ProtogenTaskSettingType<String>(
      decode: (buffer) => utf8.decode(buffer.buffer.asUint8List()),
      getWidget: (setting) => Text(setting.name)
  );

  /// Image config is the requested width and height
  static var imageInput = ProtogenTaskSettingType<List<int>>(
      decode: (buffer) => [ buffer.getUint16(0, Endian.little), buffer.getUint16(2, Endian.little), ],
      getWidget: (setting) => Text(setting.name)
  );

  /// Gif config is the requested width, height, maximum framerate, and maximum size in bytes
  static var gifInput = ProtogenTaskSettingType<List<int>>(
      decode: (buffer) => [ buffer.getUint16(0, Endian.little), buffer.getUint16(2, Endian.little), buffer.getUint8(4), buffer.getUint16(5, Endian.little), ],
      getWidget: (setting) => Text(setting.name)
  );

  static Map<int, ProtogenTaskSettingType> all = {
    0x00: boolean,
    0x01: integer,
    0x02: string,
    0x10: fileInput,
    0x11: imageInput,
    0x12: gifInput,
  };
}

class ProtogenActions extends ProtogenDataService {
  static Guid GUID = Guid(GUID_PREFIX + '0003-000000000000');

  Map<int, ProtogenTaskDefinition> taskDefinitions;

  List<ProtogenAction> actions;

  ProtogenActions(Protogen protogen, BluetoothService service) : super(protogen, service);

  @override
  void attach() async {
    if(!isSupported) {
      throw UnsupportedError("Action service not supported.");
    }

    // TODO: implement attach
  }

  @override
  void read() async {
    if(!isSupported) {
      throw UnsupportedError("Action service not supported.");
    }

    // TODO: implement read
  }

  static ProtogenActions generate(Protogen protogen) {
    var service = ProtogenActions(protogen, null);

    service.taskDefinitions = {
      0x00: ProtogenTaskDefinition("Sleep", settings: [
        ProtogenTaskSettingDefinition(ProtogenTaskSettings.integer, "Seconds", config: [ 0, 2147483647 ]),
      ]),

      0x10: ProtogenTaskDefinition("Clear Right Screen"),
      0x11: ProtogenTaskDefinition("Right Screen Bitmap", settings: [
        ProtogenTaskSettingDefinition(ProtogenTaskSettings.imageInput, "Bitmap", config: [ 64, 32 ])
      ]),
      0x12: ProtogenTaskDefinition("Right Screen Gif", settings: [
        ProtogenTaskSettingDefinition(ProtogenTaskSettings.gifInput, "Gif", config: [ 64, 32, 30, 1024 * 10 ])
      ]),

      0x13: ProtogenTaskDefinition("Clear Left Screen"),
      0x14: ProtogenTaskDefinition("Left Screen Bitmap", settings: [
        ProtogenTaskSettingDefinition(ProtogenTaskSettings.imageInput, "Bitmap", config: [ 64, 32 ])
      ]),
      0x15: ProtogenTaskDefinition("Left Screen Gif", settings: [
        ProtogenTaskSettingDefinition(ProtogenTaskSettings.gifInput, "Gif", config: [ 64, 32, 30, 1024 * 10 ])
      ]),

      0x16: ProtogenTaskDefinition("Clear Left Screen"),
      0x17: ProtogenTaskDefinition("Left Screen Bitmap", settings: [
        ProtogenTaskSettingDefinition(ProtogenTaskSettings.imageInput, "Bitmap", config: [ 64, 32 ])
      ]),
      0x18: ProtogenTaskDefinition("Top Screen Gif", settings: [
        ProtogenTaskSettingDefinition(ProtogenTaskSettings.gifInput, "Gif", config: [ 16, 16, 30, 1024 * 10 ])
      ]),
    };

    service.actions = <ProtogenAction>[
      ProtogenAction("Neutral", icon: "emotes/neutral.svg"),
      ProtogenAction("Sad", icon: "emotes/unknown.svg"),
      ProtogenAction("Angery", icon: "emotes/unknown.svg"),
      ProtogenAction("Boot", icon: "emotes/unknown.svg"),
      ProtogenAction("Boo", icon: "emotes/unknown.svg"),
      ProtogenAction("Wav", icon: "emotes/unknown.svg"),
      ProtogenAction("Hot", icon: "emotes/unknown.svg"),
      ProtogenAction("Ded", icon: "emotes/unknown.svg"),
      ProtogenAction("Overheating", icon: "emotes/unknown.svg"),
      ProtogenAction("Low Battery", icon: "emotes/unknown.svg"),
      ProtogenAction("Shut Down", icon: "emotes/unknown.svg"),
    ];

    return service;
  }
}

/// Defines a type of input for task setting fields
class ProtogenTaskSettingType<T> {
  T Function(ByteData buffer) decode;

  Widget Function(ProtogenTaskSettingDefinition<T> setting) getWidget;

  ProtogenTaskSettingType({ this.decode, this.getWidget });
}

/// The configured task defintion
class ProtogenTaskDefinition {
  String name;

  List<ProtogenTaskSettingDefinition> settings;

  ProtogenTaskDefinition(this.name, { this.settings });
}

/// The configured setting field definition for the task
class ProtogenTaskSettingDefinition<T> {
  ProtogenTaskSettingType type;

  String name;
  T config;

  ProtogenTaskSettingDefinition(this.type, this.name, { this.config });
}

/// A fully realized action definition
class ProtogenAction {
  String name;
  String icon;

  List<ProtogenTask> program;

  ProtogenAction(this.name, { this.icon = "emotes/unknown.svg" });
}

///
class ProtogenTask {
  int type;

  List<dynamic> settings;

  ProtogenTask(this.type, this.settings);
}