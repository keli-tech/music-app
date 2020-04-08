// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'MusicPlayScreen.dart';
import 'PlayListScreen.dart';
import '../services/EventBus.dart';

const List<Color> coolColors = <Color>[
  Color.fromARGB(255, 255, 59, 48),
  Color.fromARGB(255, 255, 149, 0),
  Color.fromARGB(255, 255, 204, 0),
  Color.fromARGB(255, 76, 217, 100),
  Color.fromARGB(255, 90, 200, 250),
  Color.fromARGB(255, 0, 122, 255),
  Color.fromARGB(255, 88, 86, 214),
  Color.fromARGB(255, 255, 45, 85),
];

const List<String> coolColorNames = <String>[
  'Sarcoline',
  'Coquelicot',
  'Smaragdine',
  'Mikado',
  'Glaucous',
  'Wenge',
  'Australien',
  'Banan',
  'Falu',
  'Gingerline',
  'Incarnadine',
  'Labrador',
  'Nattier',
  'Pervenche',
  'Sinoper',
  'Verditer',
  'Watchet',
  'Zaffre',
];

const int _kChildCount = 50;

class StructScreen extends StatefulWidget {
  StructScreen()
      : colorItems = List<Color>.generate(_kChildCount, (int index) {
          return coolColors[math.Random().nextInt(coolColors.length)];
        }),
        colorNameItems = List<String>.generate(_kChildCount, (int index) {
          return coolColorNames[math.Random().nextInt(coolColorNames.length)];
        });

  final List<Color> colorItems;
  final List<String> colorNameItems;

  @override
  _StructScreenState createState() => _StructScreenState();
}

class _StructScreenState extends State<StructScreen> {
  static const String routeName = '/cupertino/navigation';

  int _showMusicScreen = 0;
  var _eventBusOn;
  MusicInfoModel _musicInfoModel;

  @override
  void initState() {
    super.initState();

    _eventBusOn = eventBus.on<MusicPlayEvent>().listen((event) {
      print(event.musicPlayAction);
      print(event.musicInfoModel);

      // print(event);
      switch (event.musicPlayAction) {
        case MusicPlayAction.hide:
          _showMusicScreen = 0;
          break;
        case MusicPlayAction.show:
          _showMusicScreen = 1;
          break;
        case MusicPlayAction.play:
          _showMusicScreen = 1;
          break;
        default:
          break;
      }

      setState(() {});
    });
  }

  //销毁
  @override
  void dispose() {
    this._eventBusOn.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _statusBarHeight = MediaQuery.of(context).padding.top;

    return Center(
        child: Stack(
      children: <Widget>[
        WillPopScope(
          // Prevent swipe popping of this page. Use explicit exit buttons only.
          onWillPop: () => Future<bool>.value(true),
          child: DefaultTextStyle(
            style: CupertinoTheme.of(context).textTheme.textStyle,
            child: CupertinoTabScaffold(
              tabBar: CupertinoTabBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.double_music_note),
                    title: Text('音乐'),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.insert_drive_file),
                    title: Text('文件'),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.settings),
                    title: Text('设置'),
                  ),
                ],
              ),
              tabBuilder: (BuildContext context, int index) {
                assert(index >= 0 && index <= 2);
                switch (index) {
                  case 0:
                    return CupertinoTabView(
                      builder: (BuildContext context) => PlayListScreen(),
                      defaultTitle: '音乐',
                    );
                    break;
                  case 1:
                    return CupertinoTabView(
                      builder: (BuildContext context) => PlayListScreen(),
                      defaultTitle: '文件',
                    );
                    break;
                  case 2:
                    return CupertinoTabView(
                      builder: (BuildContext context) => PlayListScreen(),
                      defaultTitle: '设置',
                    );
                    break;
                }
                return null;
              },
            ),
          ),
        ),
        Positioned(
            right: 5,
            top: _statusBarHeight,
            child: RawMaterialButton(
              fillColor: Color.fromARGB(255, 117, 155, 255),
              constraints:
                  const BoxConstraints(minWidth: 36.0, minHeight: 36.0),
              textStyle: new TextStyle(
                fontSize: 20.0,
                color: Color.fromARGB(255, 255, 255, 255),
                decoration: TextDecoration.none,
              ),
              elevation: 4,
              shape: CircleBorder(
                  side: BorderSide(color: Color.fromARGB(255, 85, 125, 255))),
              child: Icon(Icons.music_note),
              onPressed: () {
                setState(() {
                  this._showMusicScreen = this._showMusicScreen == 1 ? 0 : 1;
                });
              },
            )),
        AnimatedPositioned(
          top: _showMusicScreen == 0 ? 1200 : 0,
          left: 0,
          duration: Duration(milliseconds: 300),
          child: MusicPlayScreen(title: 'hehaskdf'),
        ),
      ],
    ));
  }
}
