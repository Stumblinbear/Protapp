import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../protogen.dart';

class InfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var protogen = context.watch<ProtogenProvider>().active;

    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(32),
        width: double.infinity,
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                  children: [
                    Text(
                      protogen.name,
                      textAlign: TextAlign.center,
                      textScaleFactor: 2.5,
                    ),
                    Text(
                      protogen.manufacturer,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20.0, fontFamily: "Monospace"),
                    ),
                  ]
              ),
              Padding(
                  padding: EdgeInsets.all(32),
                  child: SvgPicture.asset("emotes/neutral.svg", width: 256)
              ),
              Column(
                  children: [
                    Text(
                      protogen.model,
                      style: TextStyle(fontSize: 16.0, fontFamily: "Monospace"),
                    ),
                    Text(
                      'rev. ' + protogen.softwareRevision.toString() + ' / ' + protogen.hardwareRevision.toString(),
                      style: TextStyle(fontSize: 16.0, fontFamily: "Monospace"),
                    ),
                  ]
              ),
            ],
          ),
        )
      )
    );
  }
}
