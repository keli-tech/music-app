import 'package:flutter/material.dart';

final ThemeData lightThemeData = new ThemeData(
  primarySwatch: Colors.red,
  primaryColor: Color.fromARGB(255, 231, 240, 253),
  primaryColorBrightness: Brightness.light,
  accentColor: Color.fromARGB(255, 225, 235, 250),
  cardColor: Colors.purple,
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
  // buttonBarTheme: ButtonBarThemeData(
  //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //   minWidth: 64.0,
  //   height: 30.0,
  //   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //   shape: RoundedRectangleBorder(
  //     borderRadius: BorderRadius.circular(4.0),
  //   ),
  // ),
  primaryTextTheme: TextTheme(
      title: TextStyle(
    color: Color.fromARGB(255, 106, 120, 145),
    fontSize: 20.0,
  )),
  accentTextTheme: TextTheme(
      title: TextStyle(
    color: Colors.green,
    fontSize: 14.0,
  )),
  textTheme: TextTheme(
      title: TextStyle(
    color: Colors.pink,
    fontSize: 14.0,
  )),
  backgroundColor: Color.fromARGB(255, 231, 240, 253),
);
