import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spring_button/spring_button.dart';

class EmotesPage extends StatelessWidget {
  Widget createEmoteButton(BuildContext context, {@required VoidCallback onPressed, String icon, String text}) {
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
    return Align(
      alignment: Alignment.topLeft,
      child: SafeArea(
        child: Scrollbar(
          child: GridView.count(
            primary: false,
            padding: const EdgeInsets.all(16),
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
            crossAxisCount: 2,
            children: <Widget>[
              this.createEmoteButton(context, onPressed: () {
                /*...*/
              }, icon: "emotes/neutral.svg", text: "Neutral"),
              this.createEmoteButton(context, onPressed: () {
                /*...*/
              }, icon: "emotes/unknown.svg", text: "Sad"),
              this.createEmoteButton(context, onPressed: () {
                /*...*/
              }, icon: "emotes/unknown.svg", text: "Angery"),
              this.createEmoteButton(context, onPressed: () {
                /*...*/
              }, icon: "emotes/unknown.svg", text: "Me"),
              this.createEmoteButton(context, onPressed: () {
                /*...*/
              }, icon: "emotes/unknown.svg", text: "Boot"),
              this.createEmoteButton(context, onPressed: () {
                /*...*/
              }, icon: "emotes/unknown.svg", text: "Boo"),
              this.createEmoteButton(context, onPressed: () {
                /*...*/
              }, icon: "emotes/unknown.svg", text: "Wav"),
              this.createEmoteButton(context, onPressed: () {
                /*...*/
              }, icon: "emotes/unknown.svg", text: "Borr"),
              this.createEmoteButton(context, onPressed: () {
                /*...*/
              }, icon: "emotes/unknown.svg", text: "Side 21"),
              this.createEmoteButton(context, onPressed: () {
                /*...*/
              }, icon: "emotes/unknown.svg", text: "Hot"),
              this.createEmoteButton(context, onPressed: () {
                /*...*/
              }, icon: "emotes/unknown.svg", text: "Ded"),
              this.createEmoteButton(context, onPressed: () {
                /*...*/
              }, icon: "emotes/unknown.svg", text: "Overheating"),
              this.createEmoteButton(context, onPressed: () {
                /*...*/
              }, icon: "emotes/unknown.svg", text: "Low Battery"),
              this.createEmoteButton(context, onPressed: () {
                /*...*/
              }, icon: "emotes/unknown.svg", text: "Shut Down"),
            ],
          ),
        )
      ),
    );
  }
}
