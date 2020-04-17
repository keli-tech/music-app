// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/components/%20AblumImageAnimation.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/screens/AlbumListScreen.dart';
import 'package:hello_world/screens/FileList2Screen.dart';
import 'package:hello_world/screens/PlayListDetailScreen.dart';
import 'package:hello_world/screens/PlayingScreen.dart';
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

class StructScreen extends StatefulWidget {
  static const String routeName = '/struct';

  @override
  _StructScreenState createState() => _StructScreenState();
}

class _StructScreenState extends State<StructScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  static const String routeName = '/cupertino/navigation';
  AnimationController _controller;

  var routes = {
    StructScreen.routeName: (context) => StructScreen(),
    PlayListDetailScreen.routeName: (context) => PlayListDetailScreen(),
    FileListScreen.routeName: (context) => FileListScreen(),
    FileList2Screen.routeName: (context) => FileList2Screen(),
  };
  CarouselSlider _carouselControl;
  int _showMusicScreen = 0;
  double _topMusicScreen = 0;
  var _eventBusOn;
  MusicPlayAction _musicPlayAction = MusicPlayAction.stop;

  PageController _pageController;
  int _index = 0;
  DragStartDetails _startDetails;
  Animation<double> animation;
  AnimationController controller;
  bool _showIcon = true;

  @override
  void initState() {
    super.initState();
    _initEvent();

    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);

//    _initAnimationController();
  }

  Future<Null> _playAnimation() async {
    print("action animation");
    try {
      setState(() {
        _showIcon = true;
      });
      //先正向执行动画
      await _controller.forward().orCancel;
      await _controller.reset();
      setState(() {
        _showIcon = false;
      });

      //再反向执行动画
//      await _controller.reverse().orCancel;
    } on TickerCanceled {
      // the animation got canceled, probably because we were disposed
    }
  }

  // 初始化旋转动画
  void _initAnimationController() {
    controller = new AnimationController(
        duration: const Duration(seconds: 30), vsync: this);
    //图片宽高从0变到300
    animation = new Tween(begin: 0.0, end: 720.0).animate(controller);
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        //动画执行结束时, 继续正像执行动画
        controller.reset();

        controller.forward();
      } else if (status == AnimationStatus.dismissed) {
        //动画恢复到初始状态时执行动画（正向）
        controller.forward();
      }
    });

    //停止动画（正向）
    controller.stop();
  }

  void _initEvent() {
    _eventBusOn = eventBus.on<MusicPlayEvent>().listen((event) {
      var musicInfoData = Provider.of<MusicInfoData>(context, listen: false);

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

      if (musicInfoData.playIndex != null && musicInfoData.playIndex >= 0) {
        _carouselControl.jumpToPage(musicInfoData.playIndex);
      }
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
    double windowHeight = MediaQuery.of(context).size.height;
    double windowWidth = MediaQuery.of(context).size.width;

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
                currentIndex: 2,
                iconSize: 30,
                backgroundColor: themeData.backgroundColor,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.view_list),
                    title: Text("歌单"),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.album),
                    title: Text("专辑"),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.heart_solid),
                    title: Text("红心"),
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
                assert(index >= 0 && index <= 4);
                switch (index) {
                  case 0:
                    return CupertinoTabView(
                      builder: (BuildContext context) => PlayListScreen(),
                      routes: routes,
                      defaultTitle: '歌单',
                    );
                    break;
                  case 1:
                    return CupertinoTabView(
                      builder: (BuildContext context) => AlbumListScreen(),
                      routes: routes,
                      defaultTitle: '专辑',
                    );
                    break;
                  case 2:
                    return CupertinoTabView(
                      builder: (BuildContext context) => MusicFavListScreen(),
                      routes: routes,
                      defaultTitle: '红心',
                    );
                    break;
                  case 3:
                    return CupertinoTabView(
                      builder: (BuildContext context) => FileListScreen(),
                      routes: routes,
                      defaultTitle: '文件',
                    );
                    break;
                  case 4:
                    return CupertinoTabView(
                      builder: (BuildContext context) => PlayListScreen(),
                      routes: routes,
                      defaultTitle: '设置',
                    );
                    break;
                }
                return null;
              },
            ),
          ),
        ),
        _showIcon
            ? Consumer<MusicInfoData>(
                builder: (context, musicInfoData, _) => Hero(
                  tag: "playing",
                  child: AlbumImageAnimation(
                    musicInfoModel: musicInfoData.musicInfoModel,
                    controller: _controller,
                    windowWidth: windowWidth,
                    windowHeight: windowHeight,
                  ),
                ),
              )
            : Container(),
        buildPlayControlWidget(context),
        AnimatedPositioned(
          top: _showMusicScreen == 0
              ? 1200
              : (_topMusicScreen > 0 ? _topMusicScreen : 0),
          left: 0,
          duration: Duration(milliseconds: 300),
          child: Listener(
            child: GestureDetector(
              child:
                  MusicPlayScreen(title: '', showMusicScreen: _showMusicScreen),
              onVerticalDragDown: (DragDownDetails details) {
//                print(details);
              },
              onVerticalDragStart: (DragStartDetails details) {
                _startDetails = details;
              },
              onVerticalDragEnd: (DragEndDetails details) {
                if (details.primaryVelocity > 300 ||
                    _topMusicScreen > windowHeight / 3) {
                  setState(() {
                    _showMusicScreen = 0;
                    _topMusicScreen = 0;
                  });
                } else {
                  setState(() {
                    _topMusicScreen = 0;
                  });
                }
              },
              onVerticalDragUpdate: (DragUpdateDetails details) {
                setState(() {
                  _topMusicScreen += details.delta.dy;
                });
              },
            ),
          ),
        ),
      ],
    ));
  }

  Widget buildPlayControlWidget(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Positioned(
      width: MediaQuery.of(context).size.width,
      bottom: 50, //todo
      child: Consumer<MusicInfoData>(
        builder: (context, musicInfoData, _) => Container(
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(
                color: themeData.primaryColor,
                width: 0.1,
                style: BorderStyle.solid,
              )),
            ),
            child: new FlatButton(
              splashColor: themeData.backgroundColor,
              highlightColor: themeData.backgroundColor,
              color: themeData.backgroundColor,
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    pressedOpacity: 1,
                    child: Icon(
                      _musicPlayAction == MusicPlayAction.play
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      size: 35,
                      semanticLabel: 'Add',
                    ),
                    onPressed: () {
                      if (_musicPlayAction == MusicPlayAction.play) {
                        eventBus.fire(MusicPlayEvent(MusicPlayAction.stop));
                      } else if (_musicPlayAction == MusicPlayAction.stop) {
                        eventBus.fire(MusicPlayEvent(MusicPlayAction.play));
                      } else {}
                    },
                  ),
                ),
                title: new Container(
//                    padding:
//                        EdgeInsets.only(left: 10, top: 2, right: 10, bottom: 2),
                  child: new Row(
                    children: <Widget>[
                      Expanded(
                          child: musicInfoData.musicInfoList.length <= 0
                              ? Text("")
                              : buildCarouselControl(context, musicInfoData)),
                    ],
                  ),
                ),
                trailing: Container(
                  width: 40,
                  height: 40,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    pressedOpacity: 1,
                    child: AnimatedSwitcher(
                        transitionBuilder: (child, anim) {
                          return ScaleTransition(child: child, scale: anim);
                        },
                        switchInCurve: Curves.fastLinearToSlowEaseIn,
                        switchOutCurve: Curves.fastLinearToSlowEaseIn,
                        duration: Duration(milliseconds: 300),
                        child: musicInfoData.musicInfoFavIDSet
                                .contains(musicInfoData.musicInfoModel.id)
                            ? Container(
                                key: Key("play"),
                                child: Icon(
                                  CupertinoIcons.heart_solid,
                                  color: Colors.red,
                                  size: 35,
                                ),
                              )
                            : Container(
                                key: Key("pause"),
                                child: Icon(
                                  CupertinoIcons.heart,
                                  color: Colors.red,
                                  size: 35,
                                ),
                              )),
                    onPressed: () {
                      if (musicInfoData.musicInfoFavIDSet
                          .contains(musicInfoData.musicInfoModel.id)) {
                        Provider.of<MusicInfoData>(context, listen: false)
                            .removeMusicInfoFavIDSet(
                                musicInfoData.musicInfoModel.id);
                      } else {
                        Provider.of<MusicInfoData>(context, listen: false)
                            .addMusicInfoFavIDSet(
                                musicInfoData.musicInfoModel.id);
                      }
                    },
                  ),
                ),
              ),
              onPressed: () {
                if (musicInfoData.playIndex == null ||
                    musicInfoData.playIndex < 0) {
                  return;
                }

                Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute<void>(
                  title: "sdf",
                  fullscreenDialog: true,
                  builder: (BuildContext context) =>
                      PlayingScreen(hideAction: _playAnimation
                          // colorName: colorName,
                          // index: index,
                          ),
                ));
                // todo
//                setState(() {
//                  this._showMusicScreen = this._showMusicScreen == 1 ? 0 : 1;
//                });
              },
            )),
      ),
    );
  }

  Widget buildCarouselControl(
      BuildContext context, MusicInfoData musicInfoData) {
    ThemeData themeData = Theme.of(context);

    _carouselControl = CarouselSlider(
      autoPlay: false,
      height: 45.0,
      viewportFraction: 1.0,
      initialPage:
          musicInfoData.playIndex > musicInfoData.musicInfoList.length - 1
              ? musicInfoData.musicInfoList.length - 1
              : musicInfoData.playIndex,
      onPageChanged: (onValue) {
        Provider.of<MusicInfoData>(context, listen: false)
            .setPlayIndex(onValue);
        eventBus.fire(MusicPlayEvent(MusicPlayAction.play));
      },
      items: musicInfoData.musicInfoList.map((musicInfoModel) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    musicInfoModel.title,
                    style: TextStyle(
                        fontSize: 13, color: themeData.textTheme.title.color),
                  ),
                  Text(
                    musicInfoModel.artist,
                    style: TextStyle(
                        fontSize: 10, color: themeData.textTheme.title.color),
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
    return _carouselControl;
  }
}
