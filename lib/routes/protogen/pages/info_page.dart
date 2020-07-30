import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:protapp/dark_theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:superellipse_shape/superellipse_shape.dart';

import '../../../protocol/protogen.dart';

class InfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var protogen = context.watch<ProtogenProvider>().active;

    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(32),
        width: double.infinity,
        child: FlipCard(
          direction: FlipDirection.HORIZONTAL, // default
          front: _createCardFront(context, protogen),
          back: _createCardBack(context, protogen),
        )
      )
    );
  }

  Widget _createCardFront(BuildContext context, Protogen protogen) {
    return Container(
      child: Material(
        color: Theme.of(context).cardColor,
        shape: SuperellipseShape(
          borderRadius: BorderRadius.circular(64),
        ),
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
                    protogen.info.manufacturer,
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
                    "Manufacture Date",
                    textAlign: TextAlign.center,
                    textScaleFactor: 1,
                  ),
                  Text(
                    protogen.info.manufactureDate,
                    textAlign: TextAlign.center,
                    textScaleFactor: 1.25,
                  ),
                ]
            ),
          ],
        ),
      ),
    );
  }

  Widget _createCardBack(BuildContext context, Protogen protogen) {
    return Container(
      child: Material(
        color: Theme.of(context).cardColor,
          elevation: 10,
        shape: SuperellipseShape(
          borderRadius: BorderRadius.circular(64),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
                children: [
                  Text(
                    protogen.info.manufacturer,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24.0, fontFamily: "Monospace"),
                  ),
                ]
            ),
            Column(
                children: [
                  Text(
                    protogen.info.model,
                    style: TextStyle(fontSize: 16.0, fontFamily: "Monospace"),
                  ),
                  Text(
                    'rev. ' + protogen.info.softwareRevision.toString() + ' / ' + protogen.info.hardwareRevision.toString(),
                    style: TextStyle(fontSize: 16.0, fontFamily: "Monospace"),
                  ),
                ]
            ),
          ],
        ),
      ),
    );
  }
}
