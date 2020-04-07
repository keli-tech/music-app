import 'package:flutter/material.dart';
import 'package:hello_world/screens/MusicListScreen.dart';
import 'HomeScreen.dart';
import 'MusicPlayScreen.dart';
import '../services/EventBus.dart';


import '../theme/theme.dart';

class NavigationIconView {
  NavigationIconView({
    Widget icon,
    Widget activeIcon,
    String title,
    Color color,
    Widget child,
    TickerProvider vsync,
  })  : _icon = icon,
        _color = color,
        _title = title,
        _child = child,
        item = BottomNavigationBarItem(
          icon: icon,
          activeIcon: activeIcon,
          title: Text(title),
          backgroundColor: color,
        ),
        controller = AnimationController(
          duration: kThemeAnimationDuration,
          vsync: vsync,
        ) {
    _animation = controller.drive(CurveTween(
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    ));
  }

  final Widget _child;
  final Widget _icon;
  final Color _color;
  final String _title;
  final BottomNavigationBarItem item;
  final AnimationController controller;
  Animation<double> _animation;

  FadeTransition transition(
      BottomNavigationBarType type, BuildContext context) {
    Color iconColor;

    final ThemeData themeData = Theme.of(context);
    iconColor = themeData.brightness == Brightness.light
        ? themeData.primaryColor
        : themeData.accentColor;

    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
          position: _animation.drive(
            Tween<Offset>(
              begin: const Offset(0.0, 0.02), // Slightly down.
              end: Offset.zero,
            ),
          ),
          child: _child),
    );
  }
}

class StructScreen extends StatefulWidget {
  StructScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _StructScreenState createState() => _StructScreenState();
}

class _StructScreenState extends State<StructScreen>
    with TickerProviderStateMixin {
  var _eventBusOn;
  int _currentIndex = 0;
  BottomNavigationBarType _type = BottomNavigationBarType.shifting;
  List<NavigationIconView> _navigationViews;

  @override
  void initState() {
    super.initState();

    _eventBusOn = eventBus.on<MusicPlayEvent>().listen((event) {
      print(event.musicPlayAction);
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

    _navigationViews = <NavigationIconView>[
      NavigationIconView(
        icon: const Icon(Icons.library_music),
        title: '音乐',
        color: Colors.deepPurple,
        vsync: this,
        child: _buildHome(),
      ),
      NavigationIconView(
        activeIcon: const Icon(Icons.cloud),
        icon: const Icon(Icons.cloud_queue),
        title: '文件',
        color: Colors.teal,
        vsync: this,
        child: _buildHome2(),
      ),
      // NavigationIconView(
      //   activeIcon: const Icon(Icons.favorite),
      //   icon: const Icon(Icons.favorite_border),
      //   title: '下载',
      //   color: Colors.indigo,
      //   vsync: this,
      // ),
      NavigationIconView(
        icon: const Icon(Icons.settings),
        title: '设置',
        color: Colors.purple,
        vsync: this,
        child: _buildHome3(),
      )
    ];

    _navigationViews[_currentIndex].controller.value = 1.0;
  }

  //销毁
  @override
  void dispose() {
    this._eventBusOn.cancel();
    super.dispose();
  }

  int _showMusicScreen = 0;

  Widget _buildTransitionsStack() {
    final List<FadeTransition> transitions = <FadeTransition>[
      for (NavigationIconView view in _navigationViews)
        view.transition(_type, context),
    ];

    // We want to have the newly animating (fading in) views on top.
    transitions.sort((FadeTransition a, FadeTransition b) {
      final Animation<double> aAnimation = a.opacity;
      final Animation<double> bAnimation = b.opacity;
      final double aValue = aAnimation.value;
      final double bValue = bAnimation.value;
      return aValue.compareTo(bValue);
    });

    return Stack(children: transitions);
  }

  Widget _buildHome() {
    // double _statusBarHeight = MediaQuery.of(context).padding.top;

    return Stack(children: <Widget>[
      // 功能子页
      new Center(
          child: MaterialApp(
        theme: lightThemeData,
        home: HomeScreen(title: "音乐"),
        routes: {
          "HomeScreen": (context) => HomeScreen(title: '播放'),
          "MusicListScreen": (context) => MusicListScreen(title: ''),
        },
      )),
      //
    ]);
  }

  Widget _buildHome2() {
    // double _statusBarHeight = MediaQuery.of(context).padding.top;

    return Stack(children: <Widget>[
      // 功能子页
      new Center(
          child: MaterialApp(
        theme: lightThemeData,
        home: MusicListScreen(title: "文件"),
        routes: {
          "HomeScreen": (context) => HomeScreen(title: '播放'),
          "MusicListScreen": (context) => MusicListScreen(title: ''),
        },
      )),
      //
    ]);
  }

  Widget _buildHome3() {
    // double _statusBarHeight = MediaQuery.of(context).padding.top;

    return Stack(children: <Widget>[
      // 功能子页
      new Center(
          child: MaterialApp(
        theme: lightThemeData,
        home: MusicPlayScreen(title: "设置"),
        routes: {
          "HomeScreen": (context) => HomeScreen(title: '播放'),
          "MusicListScreen": (context) => MusicListScreen(title: ''),
        },
      )),
      //
    ]);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    double _kLeadingWidth = kToolbarHeight;
    double _statusBarHeight = MediaQuery.of(context).padding.top;

    final BottomNavigationBar botNavBar = BottomNavigationBar(
      elevation: 10,
      fixedColor: lightThemeData.buttonColor,
      backgroundColor: lightThemeData.primaryColor,
      items: _navigationViews
          .map<BottomNavigationBarItem>(
              (NavigationIconView navigationView) => navigationView.item)
          .toList(),
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (int index) {
        setState(() {
          _navigationViews[_currentIndex].controller.reverse();
          _currentIndex = index;
          _navigationViews[_currentIndex].controller.forward();
        });
      },
    );

    return Scaffold(
      body: Center(
          child: Stack(
        children: <Widget>[
          _buildTransitionsStack(),
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
      )),
      bottomNavigationBar: botNavBar,
    );
  }
}
