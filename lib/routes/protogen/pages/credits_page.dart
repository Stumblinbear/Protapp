import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CreditsPage extends StatelessWidget {
  Widget createCredit({ String title, String name, String link }) {
    return GestureDetector(
      onTap: () async {
        if(await canLaunch(link)) {
          await launch(link);
        } else {
          throw 'Could not launch $link';
        }
      },
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Card(
          child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                  children: <Widget>[
                    Text(
                      title,
                      textScaleFactor: 2,
                    ),
                    Divider(),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        name,
                        textScaleFactor: 1.5,
                      ),
                    ),
                    Text(
                      link,
                      textScaleFactor: 1,
                    ),
                  ]
              )
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Credits",
                    textScaleFactor: 3.0,
                  ),
                )
              ),
              this.createCredit(
                  title: "Hardware Magician",
                  name: "Expensive black cheese",
                  link: "https://twitter.com/JtingF"
              ),
              this.createCredit(
                  title: "App Developer",
                  name: "Stumblinbear",
                  link: "https://twitter.com/theStumblinbear"
              ),
            ],
          ),
        ),
      ),
    );
  }
}
