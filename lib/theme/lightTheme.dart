import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



final ThemeData lightThemeData = new ThemeData(
  backgroundColor: Color.fromARGB(255, 244, 244, 244),
  accentColor: Color.fromARGB(255, 225, 225, 225),
  primarySwatch: Colors.brown,
  primaryColor: Colors.brown,
  brightness: Brightness.dark,
  accentColorBrightness: Brightness.dark,
  primaryColorBrightness: Brightness.dark,
  cardColor: Color.fromARGB(255, 230, 230, 230),
  dividerColor: Color.fromARGB(255, 150, 150, 150),
  buttonColor: Color.fromARGB(255, 117, 155, 255),
  buttonTheme: ButtonThemeData(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    minWidth: 64.0,
    height: 30.0,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4.0),
    ),
  ),
  iconTheme: IconThemeData(
    color: Colors.green,
  ),
  primaryTextTheme: TextTheme(
      headline: TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
      title: TextStyle(
        color: Colors.black87,
        fontSize: 16.0,
      ),
      subtitle: TextStyle(
        color: Colors.black54,
        fontSize: 12.0,
      )),
  accentTextTheme: TextTheme(
      title: TextStyle(
        color: Colors.grey,
        fontSize: 16.0,
      ),
      subtitle: TextStyle(
        color: Colors.black54,
        fontSize: 12.0,
      )),
  textTheme: TextTheme(
    title: TextStyle(
      color: Colors.black54,
      fontSize: 16.0,
    ),
    subtitle: TextStyle(
      color: Colors.black54,
      fontSize: 12.0,
    ),
    button: TextStyle(
      color: Colors.brown,
      fontSize: 18.0,
    ),
    display1: TextStyle(
      color: Colors.brown,
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
      color: Colors.brown,
      fontSize: 16.0,
    ),
    body2: TextStyle(
      color: Colors.white,
      fontSize: 13.0,
    ),
    headline: TextStyle(
      color: Colors.white,
      fontSize: 16.0,
    ),
    subhead: TextStyle(
      color: Colors.white,
      fontSize: 13.0,
    ),
  ),
  dividerTheme: DividerThemeData(
    thickness: 0.20,
  ),
);
