//import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/theme/darkTheme.dart';
import 'package:hello_world/theme/lightTheme.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'common/Global.dart';
import 'models/MusicInfoModel.dart';
import 'screens/StructScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print(
        '${record.loggerName}: ${record.level.name}: ${record.time}: ${record.message}');
  });

  String appId = "ca-app-pub-8997196463219106~5244690570";
//  FirebaseAdMob.instance.initialize(appId: appId);

  Global.init().then((onValue) {
    runApp(
      // providers
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MusicInfoData()),
        ],
        child: MyApp(),
      ),
    );
  });
}

class MyApp extends StatefulWidget {
  MyApp({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightThemeData,
      darkTheme: darkThemeData,
      home: StructScreen(),
    );
  }
}
