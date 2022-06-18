import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/components/AblumImageAnimation.dart';
import 'package:hello_world/components/PlayingControlComp.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/screens/album/PlayListDetailScreen.dart';
import 'package:hello_world/screens/album/TypeScreen.dart';
import 'package:hello_world/screens/cloudservice/CloudServiceScreen.dart';
import 'package:hello_world/screens/fav/FavListScreen.dart';
import 'package:hello_world/screens/file/FileList2Screen.dart';
import 'package:provider/provider.dart';

import 'file/FileListScreen.dart';

// 主页
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

  Animation<double> animation;
  AnimationController controller;

// 是否展示
  bool _showIcon = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);

  //  _initAnimationController();
  }

  Future<Null> _playAnimation() async {
    try {
      _controller.reset();
      setState(() {
        _showIcon = true;
      });
      await _controller.forward().orCancel;
      _controller.reset();
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
        //动画执行结束时, 继续正向执行动画
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
    _controller.dispose();

    super.dispose();
  }

  final GlobalKey<NavigatorState> firstTabNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> secondTabNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> thirdTabNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> forthTabNavKey = GlobalKey<NavigatorState>();

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
            style: themeData.textTheme.bodyText2,
            child: CupertinoTabScaffold(
              backgroundColor: themeData.backgroundColor,
              tabBar: CupertinoTabBar(
                onTap: (index) {
                  // back home only if not switching tab
                  if (_currentIndex == index) {
                    switch (index) {
                      case 0:
                        firstTabNavKey.currentState.popUntil((r) => r.isFirst);
                        break;
                      case 1:
                        secondTabNavKey.currentState.popUntil((r) => r.isFirst);
                        break;
                      case 2:
                        thirdTabNavKey.currentState.popUntil((r) => r.isFirst);
                        break;
                      case 3:
                        forthTabNavKey.currentState.popUntil((r) => r.isFirst);
                        break;
                    }
                  }
                  _currentIndex = index;
                },
                activeColor: themeData.primaryColorLight,
                inactiveColor: themeData.accentColor,
                backgroundColor: themeData.primaryColorDark,
                currentIndex: 0,
                iconSize: 30,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite),
                    label: "收藏",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.album),
                    label: "专辑",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.insert_drive_file),
                    label: "文件",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.cloud),
                    label: "云同步",
                  ),
                ],
              ),
              tabBuilder: (BuildContext context, int index) {
                assert(index >= 0 && index <= 3);
                switch (index) {
                  case 0:
                    return CupertinoTabView(
                      navigatorKey: firstTabNavKey,
                      builder: (BuildContext context) => FavListScreen(),
                      routes: routes,
                      defaultTitle: '收藏',
                    );
                    break;
                  case 1:
                    return CupertinoTabView(
                      navigatorKey: secondTabNavKey,
                      builder: (BuildContext context) => TypeScreen(),
                      routes: routes,
                      defaultTitle: '专辑',
                    );
                    break;
                  case 2:
                    return CupertinoTabView(
                      navigatorKey: thirdTabNavKey,
                      builder: (BuildContext context) => FileListScreen(),
                      routes: routes,
                      defaultTitle: '文件',
                    );
                    break;
                  case 3:
                    return CupertinoTabView(
                      navigatorKey: forthTabNavKey,
                      builder: (BuildContext context) {
                        return CloudServiceScreen();
                      },
                      defaultTitle: '云同步',
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
        // 底部播放组件
        PlayingControlComp(hideAction: _playAnimation),
      ],
    ));
  }
}
