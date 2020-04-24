import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/components/AblumImageAnimation.dart';
import 'package:hello_world/components/PlayingControlComp.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/screens/AlbumListScreen.dart';
import 'package:hello_world/screens/FileList2Screen.dart';
import 'package:hello_world/screens/PlayListDetailScreen.dart';
import 'package:provider/provider.dart';

import 'FileListScreen.dart';
import 'MusicFavListScreen.dart';
import 'PlayListScreen.dart';

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

  PageController _pageController;
  Animation<double> animation;
  AnimationController controller;
  bool _showIcon = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);

//    _initAnimationController();
  }

  Future<Null> _playAnimation() async {
    try {
      await _controller.reset();
      setState(() {
        _showIcon = true;
      });
      await _controller.forward().orCancel;
      await _controller.reset();
      setState(() {
        _showIcon = false;
      });
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

  //销毁
  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context);

    double _statusBarHeight = mq.padding.top;
    double _windowHeight = mq.size.height;
    double _windowWidth = mq.size.width;
    double _bottomBarHeight = mq.padding.bottom;

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
                currentIndex: 0,
                iconSize: 30,
                backgroundColor: themeData.backgroundColor,
                items: const <BottomNavigationBarItem>[
//                  BottomNavigationBarItem(
//                    icon: Icon(CupertinoIcons.music_note),
//                    title: Text("收藏"),
//                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite),
                    title: Text("收藏"),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.album),
                    title: Text("专辑"),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.insert_drive_file),
                    title: Text("文件"),
                  ),
                ],
              ),
              tabBuilder: (BuildContext context, int index) {
                assert(index >= 0 && index <= 2);
                switch (index) {
                  case 0:
                    return CupertinoTabView(
                      builder: (BuildContext context) => MusicFavListScreen(),
                      routes: routes,
                      defaultTitle: '收藏',
                    );
                    break;
//                  case 1:
//                    return CupertinoTabView(
//                      builder: (BuildContext context) => PlayListScreen(),
//                      routes: routes,
//                      defaultTitle: '歌单',
//                    );
//                    break;
                  case 1:
                    return CupertinoTabView(
                      builder: (BuildContext context) => AlbumListScreen(),
                      routes: routes,
                      defaultTitle: '专辑',
                    );
                    break;
                  case 2:
                    return CupertinoTabView(
                      builder: (BuildContext context) => FileListScreen(),
                      routes: routes,
                      defaultTitle: '文件',
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
                    windowWidth: _windowWidth,
                    windowHeight: _windowHeight,
                    bottomBarHeight: _bottomBarHeight,
                  ),
                ),
              )
            : Container(),
        PlayingControlComp(hideAction: _playAnimation),
      ],
    ));
  }
}
