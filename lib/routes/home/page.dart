import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
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
  Destination('Info', Icons.info, Colors.white, InfoPage()),
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
      bottomNavigationBar: Container(
        color: Theme.of(context).cardColor, // allDestinations[_currentIndex].color.withOpacity(0.25),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: GNav(
            gap: 8,
            color: Colors.grey[800],
            activeColor: allDestinations[_currentIndex].color,
            iconSize: 24,
            tabBackgroundColor: allDestinations[_currentIndex].color.withOpacity(0.25),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            duration: Duration(milliseconds: 200),
            selectedIndex: _currentIndex,
            tabs: allDestinations.map((Destination destination) {
              return GButton(
                icon: Icon(destination.icon).icon,
                text: destination.title,
              );
            }).toList(),
            onTabChange: (index) {
              setState(() {
                _currentIndex = index;
              });
            }),
      ),
    );
  }
}
