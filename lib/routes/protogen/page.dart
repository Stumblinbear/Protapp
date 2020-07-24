import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:protapp/routes/protogen/pages/actions_page.dart';
import 'package:protapp/routes/protogen/pages/info_page.dart';
import 'package:protapp/routes/protogen/pages/stream_page.dart';
import 'package:protapp/routes/protogen/pages/update_page.dart';

typedef Widget WidgetCallback();

class Destination {
  final String title;
  final IconData icon;
  final Color color;
  final Widget page;

  const Destination(this.title, this.icon, this.color, this.page);
}

List<Destination> protogenDestinations = <Destination>[
  Destination('Info', Icons.info, Colors.white, InfoPage()),
  Destination('Actions', Icons.face, Colors.orange, ActionsPage()),
  Destination('Stream', Icons.play_arrow, Colors.red, StreamPage()),
  Destination('Update', Icons.update, Colors.blue, UpdatePage()),
  // Destination('Credits', Icons.question_answer, Colors.black, CreditsPage()),
];

class ProtogenRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProtogenRouteState();
}

class _ProtogenRouteState extends State<ProtogenRoute> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: protogenDestinations[_currentIndex].page,
      bottomNavigationBar: Container(
        color: Theme.of(context).cardColor, // allDestinations[_currentIndex].color.withOpacity(0.25),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: GNav(
            gap: 8,
            color: Colors.grey[800],
            activeColor: protogenDestinations[_currentIndex].color,
            iconSize: 24,
            tabBackgroundColor: protogenDestinations[_currentIndex].color.withOpacity(0.25),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            duration: Duration(milliseconds: 200),
            selectedIndex: _currentIndex,
            tabs: protogenDestinations.map((Destination destination) {
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
