import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UpdatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Text(
                "In Development",
                textScaleFactor: 2,
              ),
            ),
            Padding(padding: EdgeInsets.all(16)),
            Center(
              child: Text(
                "<.<",
                textScaleFactor: 1.5,
              ),
            )
          ],
        ),
      ),
    );
  }
}
