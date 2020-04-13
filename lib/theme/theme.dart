import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final ThemeData lightThemeData = new ThemeData(
  primarySwatch: Colors.blue,
  primaryColor: Colors.blue,
  primaryColorBrightness: Brightness.dark,
  accentColor: Color.fromARGB(255, 225, 235, 250),
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
  // buttonBarTheme: ButtonBarThemeData(
  //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //   minWidth: 64.0,
  //   height: 30.0,
  //   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //   shape: RoundedRectangleBorder(
  //     borderRadius: BorderRadius.circular(4.0),
  //   ),
  // ),
  iconTheme: IconThemeData(
    color: Colors.grey,
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
      color: Colors.blue,
      fontSize: 18.0,
    ),
  ),
  dividerTheme: DividerThemeData(
    thickness: 0.20,
  ),
  backgroundColor: Color.fromARGB(255, 220, 220, 220),
);

final ThemeData darkThemeData = new ThemeData(
  primarySwatch: Colors.green,
  primaryColor: Colors.green,
  primaryColorBrightness: Brightness.dark,
  accentColor: Color.fromARGB(255, 10, 240, 10),
  cardColor: Colors.black87,
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
        color: Colors.grey,
        fontSize: 16.0,
      ),
      subtitle: TextStyle(
        color: Colors.white,
        fontSize: 12.0,
      )),
  textTheme: TextTheme(
    title: TextStyle(
      color: Colors.white,
      fontSize: 16.0,
    ),
    subtitle: TextStyle(
      color: Colors.white,
      fontSize: 12.0,
    ),
    button: TextStyle(
      color: Colors.green,
      fontSize: 18.0,
    ),
  ),
  dividerTheme: DividerThemeData(
    thickness: 0.20,
  ),
  backgroundColor: Color.fromARGB(255, 20, 20, 20),
);
