import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/EventBus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/**
 * 播放页
 */

class MusicPlayScreen extends StatefulWidget {
  MusicPlayScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MusicPlayScreenState createState() => _MusicPlayScreenState();
}

class MusicInfo {
  String name;
  String author;
  String info;
  String mp3Url;
  String imgUrl;
}

class _MusicPlayScreenState extends State<MusicPlayScreen> {
  Duration _duration = new Duration();
  Duration _position = new Duration();
  bool _syncSlide = true;

  MusicInfo musicInfo = new MusicInfo();

  AudioPlayerState _audioPlayerState = AudioPlayerState.COMPLETED;

  String _localFilePath = "";
  static AudioPlayer advancedPlayer;

  @override
  void initState() {
    super.initState();
    initPlayer();
    initMusic();
  }

  void initMusic() {
    musicInfo.name = "Lose it Music Play";
    musicInfo.author = "Flume ft. Vic Mensa";
    musicInfo.imgUrl =
        'http://p1.music.126.net/TYwiMwjbr5dfD0K44n-xww==/109951163409466795.jpg';
  }

  void initPlayer() {
    advancedPlayer = new AudioPlayer();

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

  Future playFile() async {
    final dir = await getApplicationDocumentsDirectory();
    var full_file = ('${dir.path}/fileName.mp3');
    var file = File(full_file);
    if (await file.exists()) {
      advancedPlayer.release();

      advancedPlayer.play(_localFilePath, isLocal: true);

      setState(() {
        _localFilePath = file.path;
      });
    }
  }

  // playLocal() async {
  //   int result = await audioPlayer.play(_localFilePath, isLocal: true);
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    double _statusBarHeight = MediaQuery.of(context).padding.top;
    double _kLeadingWidth = kToolbarHeight;
    double _barHeight = _statusBarHeight + _kLeadingWidth;

    // print(width);
    // print(height);

    return Container(
      height: height,
      color: Color.fromARGB(255, 231, 240, 253),
      child: Stack(alignment: Alignment.topCenter,
          // overflow: Overflow.clip,
          // fit: StackFit.expand,
          children: <Widget>[
            //顶栏
            Container(
                width: width,
                height: _statusBarHeight + _kLeadingWidth,
                // color: Color.fromARGB(255, 225, 235, 250),
                decoration: new BoxDecoration(
                  border: new Border.all(
                      color: Color.fromARGB(255, 225, 235, 250),
                      width: 5), // 边色与边宽度
                  boxShadow: [
                    BoxShadow(color: Color.fromARGB(255, 225, 235, 250)),
                    BoxShadow(
                        color: Color(0x99cccccc),
                        offset: Offset(2.0, 2.0),
                        blurRadius: 2.5,
                        spreadRadius: 3.0),
                    BoxShadow(
                        color: Color.fromARGB(255, 225, 235, 250),
                        offset: Offset(1.0, 1.0)),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: _statusBarHeight,
                    ),
                    Text(
                      musicInfo.name,
                      style: new TextStyle(
                        fontSize: 20.0,
                        color: Color.fromARGB(255, 106, 120, 145),
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Text(
                      musicInfo.author,
                      style: new TextStyle(
                        fontSize: 14.0,
                        color: Color.fromARGB(255, 106, 120, 145),
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                )),
            Positioned(
                top: _statusBarHeight,
                right: 5,
                child: RawMaterialButton(
                  fillColor: Color.fromARGB(255, 117, 155, 255),
                  constraints:
                      const BoxConstraints(minWidth: 36.0, minHeight: 36.0),

                  // textColor: Color.fromARGB(255, 23, 45, 196),
                  textStyle: new TextStyle(
                    fontSize: 40.0,
                    color: Color.fromARGB(255, 255, 255, 255),
                    decoration: TextDecoration.none,
                  ),
                  elevation: 4,
                  shape: CircleBorder(
                      side:
                          BorderSide(color: Color.fromARGB(255, 85, 125, 255))),
                  child: Icon(Icons.keyboard_arrow_down),
                  onPressed: () {
                    setState(() {
                      eventBus.fire(MusicPlayEvent(MusicPlayAction.hide));
                    });
                  },
                )),
            // child: RawMaterialButton(
            //     child: Icon(Icons.music_note),
            //     onPressed: () {
            //       eventBus.fire(MusicPlayEvent(MusicPlayAction.hide));
            //     })),
            // image
            Column(children: <Widget>[
              SizedBox(
                height: _barHeight * 1.2,
              ),
              CircleAvatar(
                backgroundImage: new NetworkImage(musicInfo.imgUrl),
                radius: 120.0, // --> 半径越大，图片越大
              ),
            ]),
            // 底部
            Positioned(
                bottom: 10,
                child: Column(children: <Widget>[
                  // Container(
                  //   width: width,
                  //   padding: const EdgeInsets.symmetric(vertical: 10),
                  //   child: new Slider(
                  //     label: "hwhe",
                  //     value: _position.inSeconds.toDouble(),
                  //     min: 0.0,
                  //     max: _duration.inSeconds.toDouble(),
                  //     activeColor: Color.fromARGB(255, 123, 161, 255),
                  //     inactiveColor: Color.fromARGB(255, 160, 174, 196),
                  //     onChanged: (double val) {
                  //       Duration curPosition =
                  //           new Duration(seconds: val.toInt());
                  //       // print(this._position);
                  //       setState(() {
                  //         _position = curPosition;
                  //       });
                  //     },
                  //     onChangeStart: (double val) {
                  //       print('change start');
                  //       // setState(() {
                  //       _syncSlide = false;
                  //       // });
                  //     },
                  //     onChangeEnd: (double val) {
                  //       print('change end');
                  //       // setState(() {
                  //       // });

                  //       Duration curPosition =
                  //           new Duration(seconds: val.toInt());

                  //       advancedPlayer.resume();

                  //       advancedPlayer.seek(curPosition);

                  //       setState(() {
                  //         _position = curPosition;
                  //         _syncSlide = true;
                  //       });
                  //       // initPlayer()
                  //     },
                  //   ),
                  // ),
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
                  SizedBox(
                    height: 30,
                  ),
                ])),
          ]),
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
              print('开始暂停播放');
              advancedPlayer.pause();
            } else if (_audioPlayerState == AudioPlayerState.PAUSED) {
              print('开始恢复播放');
              advancedPlayer.resume();
            } else if (_audioPlayerState == AudioPlayerState.STOPPED) {
              print('开始播放');
            } else if (_audioPlayerState == AudioPlayerState.COMPLETED) {
              playFile();
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
          Navigator.of(context).pushNamed("HomeScreen", arguments: "hi");
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
