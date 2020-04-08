import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:path_provider/path_provider.dart';

import '../services/EventBus.dart';

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
  Duration _position = new Duration();
  Duration _duration = new Duration(seconds: 1);
  bool _syncSlide = true;
  MusicInfoModel musicInfoModel = new MusicInfoModel(
    name: "",
    path: "",
    fullpath: "",
    type: "",
    syncstatus: true,
  );

  MusicInfo musicInfo = new MusicInfo();

  AudioPlayerState _audioPlayerState = AudioPlayerState.COMPLETED;

  static AudioPlayer advancedPlayer;
  var _eventBusOn;

  @override
  void initState() {
    super.initState();

    initPlayer();
    initMusic();
    print('playing');

    _eventBusOn = eventBus.on<MusicPlayEvent>().listen((event) {
      print(event.musicPlayAction);

      if (event.musicInfoModel != null &&
          musicInfoModel != event.musicInfoModel &&
          event.musicInfoModel.name != "") {
        musicInfoModel = event.musicInfoModel;
        _position = new Duration(seconds: 0);
        playFile();
      } else {
        if (_audioPlayerState != AudioPlayerState.PLAYING &&
            event.musicInfoModel != null) {
          advancedPlayer.resume();
        }
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
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void initMusic() {
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
      print('duration: $d');
      print('$_syncSlide, $_position, $d');

      if (_syncSlide &&
          (_position.inSeconds.toInt() - d.inSeconds.toInt()).abs() <= 2) {
//         print('d: $d, _position: $_position');
        setState(() => _position = d);
      }
    });

    advancedPlayer.onPlayerStateChanged.listen((AudioPlayerState s) {
      // print('Current player state: $s');
      setState(() => _audioPlayerState = s);
    });
  }

  Future playFile() async {
    if (musicInfoModel == null || musicInfoModel.name == "") {
      return;
    }
    print(musicInfoModel.name + "==name");
    final dir = await getApplicationDocumentsDirectory();
    var full_file = ('${dir.path}/' + musicInfoModel.fullpath);
    print(full_file);
    var file = File(full_file);
    if (await file.exists()) {
      print('play ok');
      advancedPlayer.play(file.path, isLocal: true);

      setState(() {
        _audioPlayerState = AudioPlayerState.PLAYING;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    double _statusBarHeight = MediaQuery.of(context).padding.top;
    double _kLeadingWidth = kToolbarHeight;
    double _barHeight = _statusBarHeight + _kLeadingWidth;

//    print(musicInfoModel.name + "--------------");
    print(_position.inSeconds.toString() + "=====");
    print(_duration.inSeconds.toString() + "2222222");

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
                      musicInfoModel.name,
                      style: new TextStyle(
                        fontSize: 20.0,
                        color: Color.fromARGB(255, 106, 120, 145),
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Text(
                      musicInfoModel.name,
                      style: new TextStyle(
                        fontSize: 13.0,
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
                      eventBus.fire(MusicPlayEvent(MusicPlayAction.hide, null));
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
                  Container(
                    width: width,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: new CupertinoSlider(
                      activeColor: Color.fromARGB(255, 123, 161, 255),
//                      inactiveColor: Color.fromARGB(255, 160, 174, 196),
                      value: _position.inSeconds.toDouble(),
                      min: 0.0,
                      max: _duration.inSeconds.toDouble(),
                      onChanged: (double value) {
                        Duration curPosition =
                            new Duration(seconds: value.toInt());
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
                        Duration curPosition =
                            new Duration(seconds: val.toInt());
                        advancedPlayer.resume();
                        advancedPlayer.seek(curPosition);
                        setState(() {
                          _position = curPosition;
                          _syncSlide = true;
                        });
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
