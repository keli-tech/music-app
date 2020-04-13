import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:provider/provider.dart';

import '../common/RotateTransform.dart';
import '../services/EventBus.dart';

/**
 * 播放页
 */

class MusicPlayScreen extends StatefulWidget {
  MusicPlayScreen({Key key, this.title, this.index}) : super(key: key);

  final String title;
  final String index;

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

class _MusicPlayScreenState extends State<MusicPlayScreen>
    with SingleTickerProviderStateMixin {
  Duration _position = new Duration();
  Duration _duration = new Duration(seconds: 1);
  bool _syncSlide = true;

  List<MusicInfoModel> musicInfoModels = [];
  int playIndex = 0;
  MusicInfoModel musicInfoModel = new MusicInfoModel(
    name: "",
    path: "",
    fullpath: "",
    type: "",
    syncstatus: true,
  );

  Animation<double> animation;
  AnimationController controller;

  AudioPlayerState _audioPlayerState = AudioPlayerState.COMPLETED;

  static AudioPlayer audioPlayer;
  var _eventBusOn;

  @override
  void initState() {
    super.initState();

    _initPlayer();
    _initEvent();
    _initAnimationController();
  }

  //销毁
  @override
  void dispose() {
    this._eventBusOn.cancel();
    audioPlayer.stop();
    audioPlayer.dispose();

    print("play screen disposed!!");
    super.dispose();
  }

  @override
  void deactivate() {
    this._eventBusOn.cancel();
    audioPlayer.stop();
    audioPlayer.dispose();

    print("play screen deactivate!!");
    super.deactivate();
  }

  // 初始化旋转动画
  void _initAnimationController() {
    controller = new AnimationController(
        duration: const Duration(seconds: 30), vsync: this);
    //图片宽高从0变到300
    animation = new Tween(begin: 0.0, end: 720.0).animate(controller);
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        //动画执行结束时反向执行动画
        controller.reset();

        controller.forward();
      } else if (status == AnimationStatus.dismissed) {
        //动画恢复到初始状态时执行动画（正向）
        controller.forward();
      }
    });

    //启动动画（正向）
    controller.stop();
  }

  // 初始化监听事件
  void _initEvent() {
    _eventBusOn = eventBus.on<MusicPlayEvent>().listen((event) {
      var musicInfoData = Provider.of<MusicInfoData>(context, listen: false);

      if (musicInfoData != null &&
          musicInfoModel !=
              musicInfoData.musicInfoModels[musicInfoData.playIndex] &&
          musicInfoData.musicInfoModels[musicInfoData.playIndex].name != "") {
        musicInfoModel = musicInfoData.musicInfoModels[musicInfoData.playIndex];

        _position = new Duration(seconds: 0);
        playFile();
        audioPlayer.resume();
        controller.forward();
      } else {}

      if (event.musicPlayAction == MusicPlayAction.play) {
        audioPlayer.resume();
        controller.forward();
      } else if (event.musicPlayAction == MusicPlayAction.stop) {
        audioPlayer.pause();
        controller.stop();
      }

      setState(() {});
    });
  }

  void _initPlayer() {
    audioPlayer = new AudioPlayer();


    audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() => _duration = d);
    });

    audioPlayer.onAudioPositionChanged.listen((Duration d) {
      if (_syncSlide &&
          (_position.inSeconds.toInt() - d.inSeconds.toInt()).abs() <= 2) {
        setState(() => _position = d);
      }
    });

    audioPlayer.onPlayerStateChanged.listen((AudioPlayerState s) {
      setState(() => _audioPlayerState = s);
    });

    audioPlayer.onPlayerCompletion.listen((onData) {
      print("finished playing");
      playNext(context);
    });
  }

  Future playFile() async {
    if (musicInfoModel == null || musicInfoModel.name == "") {
      return;
    }

    var file = FileManager.musicFilePath(musicInfoModel.fullpath);
//    audioPlayer.setUrl(file, isLocal: true);
    audioPlayer.play(file, isLocal: true);

    audioPlayer
        .setNotification(
      title: musicInfoModel.title,
      artist: musicInfoModel.artist,
      albumTitle: musicInfoModel.album,
      duration: _duration,
      imageUrl:
      'http://p2.music.126.net/VA3kAvrg2YRrxCgDMJzHnw==/3265549618941178.jpg',
    )
        .then((v) {
      print('Notification ok');
    }).catchError((e) {
      print('error with setNotification $e');
    });

    setState(() {
      _audioPlayerState = AudioPlayerState.PLAYING;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    final size = MediaQuery
        .of(context)
        .size;
    final width = size.width;
    final height = size.height;
    double _statusBarHeight = MediaQuery
        .of(context)
        .padding
        .top;
    double _kLeadingWidth = kToolbarHeight;
    double _barHeight = _statusBarHeight + _kLeadingWidth;

    return Container(
        height: height,
        color: themeData.backgroundColor,
        child: Consumer<MusicInfoData>(
          builder: (context, musicInfoData, _) =>
              Stack(alignment: Alignment.topCenter,
                  // overflow: Overflow.clip,
                  // fit: StackFit.expand,
                  children: <Widget>[
                    //顶栏
                    Container(
                        width: width,
                        height: _statusBarHeight + _kLeadingWidth,
                        color: themeData.backgroundColor,
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: _statusBarHeight,
                            ),
                          ],
                        )),
                    Positioned(
                        top: _statusBarHeight,
                        right: 5,
                        child: RawMaterialButton(
                          fillColor: themeData.primaryColor,
                          constraints:
                          const BoxConstraints(minWidth: 36.0, minHeight: 36.0),
                          textStyle: new TextStyle(
                            fontSize: 40.0,
                            decoration: TextDecoration.none,
                          ),
                          elevation: 4,
                          shape: CircleBorder(
                              side: BorderSide(
                                  color: Color.fromARGB(255, 85, 125, 255))),
                          child: Icon(Icons.keyboard_arrow_down),
                          onPressed: () {
                            setState(() {
                              eventBus.fire(
                                  MusicPlayEvent(MusicPlayAction.hide));
                            });
                          },
                        )),
                    Column(
                      children: <Widget>[
                        SizedBox(
                          height: _barHeight * 1.2,
                        ),
                        RotateTransform(
                          animation: animation,
                          //将要执行动画的子view
                          child: CircleAvatar(
                            backgroundImage: FileManager.musicAlbumPictureImage(
                                musicInfoModel.artist, musicInfoModel.album),
                            radius: width * 0.4, // --> 半径越大，图片越大
                          ),
                        ),
                      ],
                    ),

                    // 底部
                    Positioned(
                        bottom: 10,
                        child: Column(children: <Widget>[
                          SizedBox(
                            height: 60,
                          ),
                          Text(
                            musicInfoData.musicInfoModels.length > 0
                                ? '${musicInfoData.musicInfoModels[musicInfoData
                                .playIndex].title} - ${musicInfoData
                                .musicInfoModels[musicInfoData.playIndex]
                                .artist}'
                                : "",
                            style: themeData.primaryTextTheme.title,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            musicInfoData.musicInfoModels.length > 0
                                ? '${musicInfoData.musicInfoModels[musicInfoData
                                .playIndex].album}'
                                : "",
                            style: themeData.primaryTextTheme.subtitle,
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Container(
                            width: width,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: new CupertinoSlider(
                              activeColor: themeData.primaryColor,
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
                                // setState(() {
                                _syncSlide = false;
                                // });
                              },
                              onChangeEnd: (double val) {
                                Duration curPosition =
                                new Duration(seconds: val.toInt());
                                audioPlayer.resume();
                                audioPlayer.seek(curPosition);
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
        ));
  }

  Widget _genPausePlayBtn(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return AnimatedSwitcher(
        transitionBuilder: (child, anim) {
          return ScaleTransition(child: child, scale: anim);
        },
        switchInCurve: Curves.fastLinearToSlowEaseIn,
        switchOutCurve: Curves.fastOutSlowIn,
        duration: Duration(milliseconds: 300),
        child: (_audioPlayerState == AudioPlayerState.PLAYING)
            ? Container(
          key: Key("play"),
          height: 80,
          child: RawMaterialButton(
            fillColor: themeData.accentColor,
            textStyle: new TextStyle(
              fontSize: 40.0,
              color: themeData.primaryTextTheme.title.color,
              decoration: TextDecoration.none,
            ),
            elevation: 4,
            shape: CircleBorder(
                side: BorderSide(color: themeData.accentColor)),
            child: Icon(Icons.pause),
            onPressed: () {
              eventBus.fire(MusicPlayEvent(MusicPlayAction.stop));
            },
          ),
        )
            : Container(
          key: Key("pause"),
          height: 80,
          child: RawMaterialButton(
            fillColor: themeData.primaryColor,
            textStyle: new TextStyle(
              fontSize: 40.0,
              color: themeData.primaryTextTheme.title.color,
              decoration: TextDecoration.none,
            ),
            elevation: 8,
            shape: CircleBorder(
                side: BorderSide(color: themeData.primaryColor)),
            child: Icon(Icons.play_arrow),
            onPressed: () {
              if (_audioPlayerState == AudioPlayerState.PLAYING) {
//              audioPlayer.pause();
                eventBus.fire(MusicPlayEvent(MusicPlayAction.stop));
              } else if (_audioPlayerState == AudioPlayerState.PAUSED) {
                eventBus.fire(MusicPlayEvent(MusicPlayAction.play));
              } else if (_audioPlayerState == AudioPlayerState.STOPPED) {} else
              if (_audioPlayerState ==
                  AudioPlayerState.COMPLETED) {
                eventBus.fire(MusicPlayEvent(MusicPlayAction.play));
                playFile();
              }
            },
          ),
        ));
  }

  Widget _genLastBtn(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Container(
      height: 80,
      child: RawMaterialButton(
        fillColor: themeData.primaryColor,
        textStyle: new TextStyle(
          fontSize: 40.0,
          color: themeData.primaryTextTheme.title.color,
          decoration: TextDecoration.none,
        ),
        elevation: 8,
        shape: CircleBorder(side: BorderSide(color: themeData.primaryColor)),
        child: Icon(Icons.keyboard_arrow_left),
        onPressed: () {
          playPrev(context);
        },
      ),
    );
  }

  Widget _genNextBtn(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Container(
      height: 80,
      child: RawMaterialButton(
        fillColor: themeData.primaryColor,
        textStyle: new TextStyle(
          fontSize: 40.0,
          color: themeData.primaryTextTheme.title.color,
          decoration: TextDecoration.none,
        ),
        elevation: 8,
        shape: CircleBorder(side: BorderSide(color: themeData.primaryColor)),
        child: Icon(Icons.keyboard_arrow_right),
        onPressed: () {
          playNext(context);
        },
      ),
    );
  }

  void playPrev(BuildContext context) {
    var musicInfoData = Provider.of<MusicInfoData>(context, listen: false);
    int newIndex = musicInfoData.playIndex == 0
        ? musicInfoData.musicInfoModels.length - 1
        : musicInfoData.playIndex - 1;

    Provider.of<MusicInfoData>(context, listen: false).setPlayIndex(newIndex);

    controller.reset();
    controller.forward();
    eventBus.fire(MusicPlayEvent(MusicPlayAction.play));
  }

  void playNext(BuildContext context) {
    var musicInfoData = Provider.of<MusicInfoData>(context, listen: false);
    int newIndex =
    musicInfoData.playIndex < musicInfoData.musicInfoModels.length - 1
        ? musicInfoData.playIndex + 1
        : 0;

    Provider.of<MusicInfoData>(context, listen: false).setPlayIndex(newIndex);

    controller.reset();
    controller.forward();
    eventBus.fire(MusicPlayEvent(MusicPlayAction.play));
  }
}
