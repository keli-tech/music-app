import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'common/Global.dart';
import 'models/MusicInfoModel.dart';
import 'screens/StructScreen.dart';
import 'theme/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.loggerName}: ${record.level.name}: ${record.time}: ${record.message}');
  });

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
      // darkThemeData or lightThemeData or testThemeData
      theme: testThemeData,
      home: StructScreen(),
    );
  }
}
