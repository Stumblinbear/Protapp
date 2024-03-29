import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:protapp/protocol/actions.dart';
import 'package:protapp/protocol/protogen.dart';
import 'package:reorderables/reorderables.dart';
import 'package:spring_button/spring_button.dart';
import 'package:provider/provider.dart';

class ActionsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ActionsPageState();
}

class _ActionsPageState extends State<ActionsPage> {
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
  }

  Widget createActionButton(BuildContext context, {@required VoidCallback onPressed, String icon, String text}) {
    return SpringButton(
        SpringButtonType.WithOpacity,
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SvgPicture.asset(icon, width: 128),
            Text(text, style: TextStyle(fontWeight: FontWeight.w400), textScaleFactor: 1.25),
          ],
        ),
        onTap: onPressed);
  }

  @override
  Widget build(BuildContext context) {
    var actions = context.watch<ProtogenProvider>().active.actions.actions;

    return SafeArea(
        child: Scaffold(
          body: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: double.infinity,
                      child: ReorderableWrap(
                        spacing: 4.0,
                        runSpacing: 16.0,
                        padding: EdgeInsets.all(8),
                        alignment: WrapAlignment.spaceEvenly,
                        children: actions.map((action) => this.createActionButton(context, onPressed: () {
                          // TODO: do.
                        }, icon: action.icon, text: action.name)).toList(),
                        onReorderStarted: (int index) {
                          setState(() {
                            _dragging = true;
                          });
                        },
                        onNoReorder: (int index) {
                          setState(() {
                            _dragging = false;
                          });
                        },
                        onReorder: (int oldIndex, int newIndex) {
                          setState(() {
                            _dragging = false;

                            var item = actions.removeAt(oldIndex);
                            actions.insert(newIndex, item);
                          });
                        },
                      ),
                    )
                  ),
                ),
              ),
              ...(_dragging
                  ? [
                Container(
                  color: Theme.of(context).buttonColor,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: DragTarget<int>(
                          builder: (context, candidateData, rejectedData) {
                            return Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                "Delete",
                                textAlign: TextAlign.center,
                                textScaleFactor: 2,
                              ),
                            );
                          },
                          onWillAccept: (data) => true,
                          onAccept: (index) {
                            if(index == actions.length - 1) {
                              WidgetsBinding.instance.addPostFrameCallback((context) =>
                              {
                                setState(() {
                                  actions.removeAt(index);
                                })
                              });
                            }else{
                              setState(() {
                                actions.removeAt(index);
                              });
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: DragTarget<int>(
                          builder: (context, candidateData, rejectedData) {
                            return Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                "Edit",
                                textAlign: TextAlign.center,
                                textScaleFactor: 2,
                              ),
                            );
                          },
                          onWillAccept: (data) => true,
                          onAccept: (index) {
                            Navigator.pushNamed(context, '/protogen/action', arguments: actions[index]);
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ]
                  : []),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/protogen/action', arguments: ProtogenAction("New Action"));
            },
          ),
        )
    );
  }
}