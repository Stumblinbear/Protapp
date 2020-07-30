import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:protapp/protocol/actions.dart';
import 'package:protapp/protocol/protogen.dart';
import 'package:reorderables/reorderables.dart';
import 'package:spring_button/spring_button.dart';
import 'package:provider/provider.dart';

class NewActionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NewActionPageState();
}

class _NewActionPageState extends State<NewActionPage> {
  @override
  void initState() {
    super.initState();
  }

  Widget createButton(dynamic trigger) {}

  @override
  Widget build(BuildContext context) {
    var taskDefinitions = context.watch<ProtogenProvider>().active.actions.taskDefinitions;

    var action = ModalRoute.of(context).settings.arguments as ProtogenAction;

    var tasks = <Widget>[];

    tasks.add(Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Card(
          child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[Text("Update Side Screen")],
              )),
        )));

    ScrollController _scrollController = PrimaryScrollController.of(context) ?? ScrollController();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('Action Editor')),
        body: CustomScrollView(controller: _scrollController, slivers: <Widget>[
          SliverToBoxAdapter(
              child: Column(children: <Widget>[
            Padding(
              padding: EdgeInsets.all(32),
              child: SpringButton(
                SpringButtonType.WithOpacity,
                SvgPicture.asset(action.icon, width: 128),
                onTap: () {},
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Action Name',
                ),
                initialValue: action.name,
              ),
            )
          ])),
          ReorderableSliverList(delegate: ReorderableSliverChildListDelegate(tasks), onReorder: (oldIndex, newIndex) {}),
          SliverToBoxAdapter(
              child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: FlatButton(
                    child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[Text("Add new Task")],
                        )),
                  ))),
        ]),
      ),
    );
  }
}
