import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:protapp/routes/home/pages/credits_page.dart';
import 'package:protapp/routes/home/pages/emotes_page.dart';
import 'package:protapp/routes/home/pages/info_page.dart';
import 'package:protapp/routes/home/pages/stream_page.dart';
import 'package:protapp/routes/home/pages/update_page.dart';

typedef Widget WidgetCallback();

class Destination {
  final String title;
  final IconData icon;
  final Color color;
  final Widget page;

  const Destination(this.title, this.icon, this.color, this.page);
}

List<Destination> allDestinations = <Destination>[
  Destination('Info', Icons.info, Colors.black, InfoPage()),
  Destination('Emotes', Icons.face, Colors.orange, EmotesPage()),
  Destination('Stream', Icons.play_arrow, Colors.red, StreamPage()),
  Destination('Update', Icons.update, Colors.blue, UpdatePage()),
  // Destination('Credits', Icons.question_answer, Colors.black, CreditsPage()),
];

class HomeRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: allDestinations.map<Widget>((Destination destination) {
            return destination.page;
          }).toList(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: allDestinations.map((Destination destination) {
            return BottomNavigationBarItem(icon: Icon(destination.icon), backgroundColor: destination.color, title: Text(destination.title));
          }).toList(),
        ));
  }
}
