import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:protapp/protogen.dart';

class NewActionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NewActionPageState();
}

class _NewActionPageState extends State<NewActionPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var action = ModalRoute.of(context).settings.arguments as ProtogenAction;

    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
                title: Text('Action Editor')
            ),
          body: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  Text(action.name, textAlign: TextAlign.center,),
                  Text("aaaaaaa")
                ],
              ),
            ),
          ),
        ),
    );
  }
}