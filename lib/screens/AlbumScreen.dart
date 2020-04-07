import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'HomeScreen.dart';
import 'MusicPlayScreen.dart';
import 'AlbumScreen.dart';

class AlbumScreen extends StatefulWidget {
  AlbumScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AlbumScreenState createState() => _AlbumScreenState();
}

class MusicInfo {
  String name;
  String author;
  String info;
  String mp3Url;
  String imgUrl;
}

class _AlbumScreenState extends State<AlbumScreen> {
  Duration _duration = new Duration();
  Duration _position = new Duration();
  bool _syncSlide = true;

  MusicInfo musicInfo = new MusicInfo();

  AudioPlayerState _audioPlayerState = AudioPlayerState.COMPLETED;

  static AudioPlayer advancedPlayer;
  AudioCache audioCache;

  @override
  void initState() {
    super.initState();
    initPlayer();
    initMusic();
  }

  void initMusic() {
    musicInfo.name = "Lose it";
    musicInfo.author = "Flume ft. Vic Mensa";
    musicInfo.imgUrl =
        'http://p1.music.126.net/TYwiMwjbr5dfD0K44n-xww==/109951163409466795.jpg';
  }

  void initPlayer() {
    advancedPlayer = new AudioPlayer();
    audioCache = new AudioCache(fixedPlayer: advancedPlayer);

    advancedPlayer.onDurationChanged.listen((Duration d) {
      print('Max duration: $d');
      setState(() => _duration = d);
    });

    advancedPlayer.onAudioPositionChanged.listen((Duration d) {
      // print('sync: $syncSlide');

      if (_syncSlide &&
          (_position.inSeconds.toInt() - d.inSeconds.toInt()).abs() <= 2) {
        // print('d: $d, _position: $_position');
        setState(() => _position = d);
      }
    });

    advancedPlayer.onPlayerStateChanged.listen((AudioPlayerState s) {
      // print('Current player state: $s');
      setState(() => _audioPlayerState = s);
    });
  }

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // initialRoute: "AlbumScreen", //名为"/"的路由作为应用的home(首页)
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),

      home: HomeScreen(title: "234234"),
      //注册路由表
      routes: {
        "HomeScreen2": (context) => MusicPlayScreen(title: '播放'),
        "HomeScreen": (context) => HomeScreen(title: '播放'),
        "new_page": (context) => HomeScreen(),
        "index": (context) =>
            HomeScreen(title: 'Flutter 23 Home Page'), //注册首页路由
        // "tip2": (context) {
        //   return TipRoute(text: ModalRoute.of(context).settings.arguments);
        // },
      },
    );

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 231, 240, 253),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 231, 240, 253),
        title: Text(widget.title),
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        //悬浮按钮
        child: Icon(Icons.add),
        onPressed: (() => {
              Navigator.of(context).pushNamed("HomeScreen", arguments: "hi")
            }), // new
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints.expand(),
          child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center, //指定未定位或部分定位widget的对齐方式
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Column(children: <Widget>[
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 80),
                            child: new CircleAvatar(
                              backgroundImage:
                                  new NetworkImage(musicInfo.imgUrl),
                              radius: 130.0, // --> 半径越大，图片越大
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ]),
                ),
                Positioned(
                    bottom: 50.0,
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            musicInfo.name,
                            style: new TextStyle(
                              fontSize: 40.0,
                              color: Color.fromARGB(255, 106, 120, 145),
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                        Text(
                          musicInfo.author,
                          style: new TextStyle(
                            fontSize: 20.0,
                            color: Color.fromARGB(255, 160, 174, 196),
                            decoration: TextDecoration.none,
                          ),
                        ),
                        Container(
                          width: 400,
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: new Slider(
                            label: "hwhe",
                            value: _position.inSeconds.toDouble(),
                            min: 0.0,
                            max: _duration.inSeconds.toDouble(),
                            activeColor: Color.fromARGB(255, 123, 161, 255),
                            inactiveColor: Color.fromARGB(255, 160, 174, 196),
                            onChanged: (double val) {
                              Duration curPosition =
                                  new Duration(seconds: val.toInt());
                              // print(this._position);
                              setState(() {
                                _position = curPosition;
                              });
                            },
                            onChangeStart: (double val) {
                              print('change start');
                              // setState(() {
                              _syncSlide = false;
                              // });
                            },
                            onChangeEnd: (double val) {
                              print('change end');
                              // setState(() {
                              // });

                              Duration curPosition =
                                  new Duration(seconds: val.toInt());

                              advancedPlayer.resume();

                              advancedPlayer.seek(curPosition);

                              setState(() {
                                _position = curPosition;
                                _syncSlide = true;
                              });

                              // initPlayer()
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _genLastBtn(context),
                            SizedBox(
                              width: 20,
                            ),
                            _genPausePlayBtn(context),
                            SizedBox(
                              width: 20,
                            ),
                            _genNextBtn(context),
                          ],
                        ),
                      ],
                    )),
              ]),
        ),
      ),
    );
  }

  Widget _genPausePlayBtn(BuildContext context) {
    if (_audioPlayerState == AudioPlayerState.PLAYING) {
      return Container(
        height: 80,
        child: RawMaterialButton(
          fillColor: Color.fromARGB(255, 117, 155, 255),
          // textColor: Color.fromARGB(255, 23, 45, 196),
          textStyle: new TextStyle(
            fontSize: 40.0,
            color: Color.fromARGB(255, 255, 255, 255),
            decoration: TextDecoration.none,
          ),
          elevation: 4,
          shape: CircleBorder(
              side: BorderSide(color: Color.fromARGB(255, 85, 125, 255))),
          child: Icon(Icons.pause),
          onPressed: () {
            print(_audioPlayerState);
            print('开始暂停');
            advancedPlayer.pause();
          },
        ),
      );
    } else {
      return Container(
        height: 80,
        child: RawMaterialButton(
          fillColor: Color.fromARGB(255, 229, 238, 253),
          // textColor: Color.fromARGB(255, 23, 45, 196),
          textStyle: new TextStyle(
            fontSize: 40.0,
            color: Color.fromARGB(255, 106, 120, 145),
            decoration: TextDecoration.none,
          ),
          elevation: 8,
          shape: CircleBorder(
              side: BorderSide(color: Color.fromARGB(255, 222, 232, 249))),
          child: Icon(Icons.play_arrow),
          onPressed: () {
            print(_audioPlayerState);

            if (_audioPlayerState == AudioPlayerState.PLAYING) {
              print('开始暂停');
              advancedPlayer.pause();
            } else if (_audioPlayerState == AudioPlayerState.PAUSED) {
              print('开始恢复播放');
              advancedPlayer.resume();
            } else if (_audioPlayerState == AudioPlayerState.STOPPED) {
              print('开始播放');
            } else if (_audioPlayerState == AudioPlayerState.COMPLETED) {
              audioCache.play('audio.mp3');
            }
          },
        ),
      );
    }
  }

  Widget _genLastBtn(BuildContext context) {
    return Container(
      height: 80,
      child: RawMaterialButton(
        fillColor: Color.fromARGB(255, 229, 238, 253),
        // textColor: Color.fromARGB(255, 23, 45, 196),
        textStyle: new TextStyle(
          fontSize: 40.0,
          color: Color.fromARGB(255, 106, 120, 145),
          decoration: TextDecoration.none,
        ),
        elevation: 8,
        shape: CircleBorder(
            side: BorderSide(color: Color.fromARGB(255, 222, 232, 249))),
        child: Icon(Icons.keyboard_arrow_left),
        onPressed: () {
          // Navigator.of(context).pushNamed("new_page", arguments: "hi");
        },
      ),
    );
  }

  Widget _genNextBtn(BuildContext context) {
    return Container(
      height: 80,
      child: RawMaterialButton(
        fillColor: Color.fromARGB(255, 229, 238, 253),
        // textColor: Color.fromARGB(255, 23, 45, 196),
        textStyle: new TextStyle(
          fontSize: 40.0,
          color: Color.fromARGB(255, 106, 120, 145),
          decoration: TextDecoration.none,
        ),
        elevation: 8,
        shape: CircleBorder(
            side: BorderSide(color: Color.fromARGB(255, 222, 232, 249))),
        child: Icon(Icons.keyboard_arrow_right),
        onPressed: () {
          Navigator.of(context).pushNamed("new_page", arguments: "hi");
        },
      ),
    );
  }
}
