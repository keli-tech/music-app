import 'package:flutter/material.dart';
import 'package:hello_world/screens/FileList2Screen.dart';
import 'package:hello_world/screens/FileListScreen.dart';
import 'package:hello_world/screens/PlayListDetailScreen.dart';
import 'package:provider/provider.dart';

import 'common/Global.dart';
import 'models/MusicInfoModel.dart';
import 'screens/StructScreen.dart';
import 'theme/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Global.init().then((onValue) {
    runApp(
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
      // darkThemeData or lightThemeData or testThemeData
      theme: testThemeData,
      title: 'Keli Music',
      home: StructScreen(),
    );
  }
}
