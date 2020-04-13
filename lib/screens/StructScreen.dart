// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:provider/provider.dart';

import '../services/EventBus.dart';
import 'FileListScreen.dart';
import 'MusicFavListScreen.dart';
import 'MusicPlayScreen.dart';
import 'PlayListScreen.dart';

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
  MusicPlayAction _musicPlayAction = MusicPlayAction.stop;

  PageController _pageController;
  int _index = 0;

  MusicInfoModel _musicInfoModel = new MusicInfoModel(
    name: "",
    path: "",
    fullpath: "",
    type: "",
    syncstatus: true,
  );

  @override
  void initState() {
    super.initState();

    _pageController = PageController(

      initialPage: _index, //默认在第几个
      viewportFraction: 1, // 占屏幕多少，1为占满整个屏幕
      keepPage: true, //是否保存当前 Page 的状态，如果保存，下次回复保存的那个 page，initialPage被忽略，
      //如果为 false 。下次总是从 initialPage 开始。
    );
//    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
//      _index++;
//      _pageController.animateToPage(
//        _index % 3, //跳转到的位置
//        duration: Duration(milliseconds: 16), //跳转的间隔时间
//        curve: Curves.fastOutSlowIn, //跳转动画
//      );
//    });

    _eventBusOn = eventBus.on<MusicPlayEvent>().listen((event) {
      var newMusicInfoModel =
          Provider.of<MusicInfoData>(context, listen: false);

      if (newMusicInfoModel != null &&
          _musicInfoModel != newMusicInfoModel.musicInfoModel &&
          newMusicInfoModel.musicInfoModel.name != "") {
        _musicInfoModel = newMusicInfoModel.musicInfoModel;
      } else {}

      if (event.musicPlayAction == MusicPlayAction.play ||
          event.musicPlayAction == MusicPlayAction.stop) {
        _musicPlayAction = event.musicPlayAction;
      }
      switch (event.musicPlayAction) {
        case MusicPlayAction.hide:
          _showMusicScreen = 0;
          break;
        case MusicPlayAction.show:
          _showMusicScreen = 1;
          break;
        case MusicPlayAction.play:
//          _showMusicScreen = 1;
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
    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _statusBarHeight = MediaQuery.of(context).padding.top;

    ThemeData themeData = Theme.of(context);
    return Center(
        child: Stack(
      children: <Widget>[
        WillPopScope(
          // Prevent swipe popping of this page. Use explicit exit buttons only.
          onWillPop: () => Future<bool>.value(true),
          child: DefaultTextStyle(
            style: themeData.textTheme.body1,
            child: CupertinoTabScaffold(
              backgroundColor: themeData.backgroundColor,
              tabBar: CupertinoTabBar(
                iconSize: 30,
                backgroundColor: themeData.backgroundColor,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.heart_solid),
                    title: Text("红心"),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.album),
                    title: Text("歌单"),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.insert_drive_file),
                    title: Text("文件"),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.settings_solid),
                    title: Text("设置"),
                  ),
                ],
              ),
              tabBuilder: (BuildContext context, int index) {
                assert(index >= 0 && index <= 3);
                switch (index) {
                  case 0:
                    return CupertinoTabView(
                      builder: (BuildContext context) => MusicFavListScreen(),
                      defaultTitle: '红心',
                    );
                    break;
                  case 1:
                    return CupertinoTabView(
                      builder: (BuildContext context) => PlayListScreen(),
                      defaultTitle: '歌单',
                    );
                    break;
                  case 2:
                    return CupertinoTabView(
                      builder: (BuildContext context) => FileListScreen(),
                      defaultTitle: '文件',
                    );
                    break;
                  case 3:
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
        buildPlayControlWidget(context),
        AnimatedPositioned(
          top: _showMusicScreen == 0 ? 1200 : 0,
          left: 0,
          duration: Duration(milliseconds: 300),
          child: MusicPlayScreen(title: ''),
        ),
      ],
    ));
  }

  Widget buildPlayControlWidget(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Positioned(
      right: 5,
      left: 5,
      bottom: 90,
      child: Consumer<MusicInfoData>(
          builder: (context, musicInfoData, _) => new RawMaterialButton(
                child: Card(
                  elevation: 10,
//                margin: EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
                  child: new Container(
                    padding:
                        EdgeInsets.only(left: 10, top: 2, right: 10, bottom: 2),
                    child: new Row(
                      children: <Widget>[
                        IconButton(
                          icon: new Icon(
                            _musicPlayAction == MusicPlayAction.play
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: themeData.primaryColor,
                            size: 30,
                          ),
                          onPressed: () {
                            if (_musicPlayAction == MusicPlayAction.play) {
                              eventBus
                                  .fire(MusicPlayEvent(MusicPlayAction.stop));
                            } else if (_musicPlayAction ==
                                MusicPlayAction.stop) {
                              eventBus
                                  .fire(MusicPlayEvent(MusicPlayAction.play));
                            } else {}
                          },
                        ),

                        Expanded(
                          child: Container(
                            height: 40,
                            child: PageView(
                              scrollDirection: Axis.horizontal,
                              reverse: true,
                              controller: _pageController,
                              physics: ClampingScrollPhysics(),
                              pageSnapping: true,
                              onPageChanged: (index) {
                                print('index=====$index');
                              },
                              children: <Widget>[
                                Container(
                                  color: Colors.tealAccent,
                                  child: Center(
                                    child: Text(
                                      '第1页',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 18.0),
                                    ),
                                  ),
                                ),
                                Container(
                                  color: Colors.greenAccent,
                                  child: Center(
                                    child: Text(
                                      '第2页',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 20.0),
                                    ),
                                  ),
                                ),
                                Container(

                                  color: Colors.deepOrange,
                                  child: Center(
                                    child: Text(
                                      '第3页',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 20.0),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),

//                        Expanded(
//                          child: Center(
//                            child: Row(
//                              children: <Widget>[
//                                Text(
//                                  musicInfoData.musicInfoModels.length > 0
//                                      ? '${musicInfoData.musicInfoModels[musicInfoData.playIndex].title}'
//                                      : "",
//                                  style: TextStyle(
//                                      fontSize: 13,
//                                      color: themeData
//                                          .primaryTextTheme.title.color),
//                                ),
//                                Text(
//                                  musicInfoData.musicInfoModels.length > 0
//                                      ? '${musicInfoData.musicInfoModels[musicInfoData.playIndex].artist}'
//                                      : "",
//                                  style: TextStyle(
//                                      fontSize: 10,
//                                      color: themeData
//                                          .accentTextTheme.title.color),
//                                ),
//                              ],
//                            ),
//                          ),
//                        ),
                        IconButton(
                          icon: new Icon(
                            _musicPlayAction == MusicPlayAction.play
                                ? CupertinoIcons.heart_solid
                                : CupertinoIcons.heart_solid,
                            color: Colors.red,
                            size: 30,
                          ),
                          onPressed: () {
                            if (_musicPlayAction == MusicPlayAction.play) {
                              eventBus
                                  .fire(MusicPlayEvent(MusicPlayAction.stop));
                            } else if (_musicPlayAction ==
                                MusicPlayAction.stop) {
                              eventBus
                                  .fire(MusicPlayEvent(MusicPlayAction.play));
                            } else {}
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    this._showMusicScreen = this._showMusicScreen == 1 ? 0 : 1;
                  });
                },
              )),
    );
  }
}
