import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final ThemeData darkThemeData = new ThemeData(
  primarySwatch: Colors.lightGreen,
  primaryColor: Colors.lightGreen,
  primaryColorBrightness: Brightness.dark,
  accentColor: Colors.lightGreenAccent,
  // cardColor: Colors.black87,
  dividerColor: Color.fromARGB(255, 150, 150, 150),
  buttonColor: Colors.white,
  iconTheme: IconThemeData(
    color: Colors.white,
  ),
  primaryTextTheme: TextTheme(
      title: TextStyle(
        color: Colors.white,
        fontSize: 16.0,
      ),
      subtitle: TextStyle(
        color: Colors.grey,
        fontSize: 12.0,
      )),
  accentTextTheme: TextTheme(
      title: TextStyle(
        color: Colors.white,
        fontSize: 16.0,
      ),
      subtitle: TextStyle(
        color: Colors.grey,
        fontSize: 12.0,
      )),
  textTheme: TextTheme(
    title: TextStyle(
      color: Colors.white,
      fontSize: 16.0,
    ),
    subtitle: TextStyle(
      color: Colors.grey,
      fontSize: 12.0,
    ),
    button: TextStyle(
      color: Colors.white,
      fontSize: 18.0,
    ),
    display1: TextStyle(
      color: Colors.green,
      fontSize: 16.0,
    ),
    display2: TextStyle(
      color: Colors.yellow,
      fontSize: 16.0,
    ),
    display3: TextStyle(
      color: Colors.red,
      fontSize: 16.0,
    ),
    display4: TextStyle(
      color: Colors.grey,
      fontSize: 16.0,
    ),
    body1: TextStyle(
      color: Colors.white,
      fontSize: 16.0,
    ),
    body2: TextStyle(
      color: Colors.white70,
      fontSize: 13.0,
    ),
  ),
  dividerTheme: DividerThemeData(
    thickness: 0.20,
  ),
  backgroundColor: Color.fromARGB(255, 20, 20, 20),
);
