import 'package:audioplayers/audioplayers.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
class PlayingScreen extends StatefulWidget {
  PlayingScreen({Key key, this.title, this.showMusicScreen, this.hideAction})
      : super(key: key);

  final String title;
  int showMusicScreen;
  Future<Null> Function() hideAction;

  @override
  _PlayingScreenState createState() => _PlayingScreenState();
}

class MusicInfo {
  String name;
  String author;
  String info;
  String mp3Url;
  String imgUrl;
}

class _PlayingScreenState extends State<PlayingScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Duration _position = new Duration();
  Duration _duration = new Duration(seconds: 1);
  bool _syncSlide = true;
  CarouselSlider _carouselControl;
  String _currentDurationTime = "";
  String _durationTime = "";

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

    print("init");
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
    controller.dispose();

    print("play screen disposed!!");
    super.dispose();
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

    //启动动画（正向） todo stop
    controller.forward();
  }

  // 初始化监听事件
  void _initEvent() {
    _eventBusOn = eventBus.on<MusicPlayEvent>().listen((event) {
      var musicInfoData = Provider.of<MusicInfoData>(context, listen: false);

      if (musicInfoData != null &&
          musicInfoModel !=
              musicInfoData.musicInfoList[musicInfoData.playIndex] &&
          musicInfoData.musicInfoList[musicInfoData.playIndex].name != "") {
        musicInfoModel = musicInfoData.musicInfoList[musicInfoData.playIndex];

        _position = new Duration(seconds: 0);
        playFile();

        _carouselControl.jumpToPage(musicInfoData.playIndex);

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
      var second = d.inSeconds % 60;
      String secondStr =
          second < 10 ? "0" + second.toString() : second.toString();
      int minute = (d.inSeconds.toInt() / 60).round().toInt();
      String minuteStr =
          minute < 10 ? "0" + minute.toString() : minute.toString();

      setState(() {
        _duration = d;
        _durationTime = '$minuteStr:$secondStr';
      });
    });

    audioPlayer.onAudioPositionChanged.listen((Duration d) {
      if (_syncSlide &&
          (_position.inSeconds.toInt() - d.inSeconds.toInt()).abs() <= 2) {
        var second = d.inSeconds % 60;
        String secondStr =
            second < 10 ? "0" + second.toString() : second.toString();
        int minute = (d.inSeconds.toInt() / 60).round().toInt();
        String minuteStr =
            minute < 10 ? "0" + minute.toString() : minute.toString();
        setState(() {
          _position = d;
          _currentDurationTime = '$minuteStr:$secondStr';
        });
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
    var musicInfoData = Provider.of<MusicInfoData>(context, listen: false);

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    double _statusBarHeight = MediaQuery.of(context).padding.top;
    double _kLeadingWidth = kToolbarHeight;
    double _barHeight = _statusBarHeight + _kLeadingWidth;

    return Container(
      height: height,
      color: themeData.primaryColor,
      child: CupertinoPageScaffold(
        backgroundColor: themeData.primaryColor,
        child: Consumer<MusicInfoData>(
          builder: (context, musicInfoData, _) =>
              //顶栏
              Column(children: <Widget>[
            Expanded(
              child: Container(
                width: width,
                height: width,
                child: Hero(
                  tag: "playing",
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Transform.scale(
                          scale: 1.8,
                          child: RotateTransform(
                            animation: animation,
                            //将要执行动画的子view
                            child: FlatButton(
                              splashColor: themeData.primaryColor,
                              highlightColor: themeData.primaryColor,
                              color: themeData.primaryColor,
                              onPressed: _playPauseAction,
                              child: CircleAvatar(
                                backgroundColor: Theme.of(context).textTheme.body2.color,
                                radius: width * 0.35, // --> 半径越大，图片越大
                                child: Center(
                                  child: Container(
                                    key: Key("start"),
                                    height: width * 0.7 - 16,
                                    width: width * 0.7 - 16,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          width * 0.35 - 8.0),
                                      image: DecorationImage(
                                          fit: BoxFit.fill, //这个地方很重要，需要设置才能充满
                                          image: FileManager
                                              .musicAlbumPictureImage(
                                                  musicInfoData
                                                      .musicInfoModel.artist,
                                                  musicInfoData
                                                      .musicInfoModel.album)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 底部
            Text(
              musicInfoData.musicInfoList.length > 0
                  ? '${musicInfoData.musicInfoList[musicInfoData.playIndex].title} - ${musicInfoData.musicInfoList[musicInfoData.playIndex].artist}'
                  : "",
              style: themeData.textTheme.subtitle,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              musicInfoData.musicInfoList.length > 0
                  ? '${musicInfoData.musicInfoList[musicInfoData.playIndex].album}'
                  : "",
              style: themeData.textTheme.title,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Container(
                width: 40,
                child: Text(
                  _currentDurationTime,
                  style: themeData.textTheme.subtitle,
                ),
              ),
              Container(
                width: width - 100,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: new CupertinoSlider(
                  activeColor: themeData.textTheme.body2.color,
                  value: _position.inSeconds.toDouble(),
                  min: 0.0,
                  max: _duration.inSeconds.toDouble(),
                  onChanged: (double value) {
                    Duration curPosition = new Duration(seconds: value.toInt());
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
                    Duration curPosition = new Duration(seconds: val.toInt());
                    audioPlayer.resume();
                    audioPlayer.seek(curPosition);
                    setState(() {
                      _position = curPosition;
                      _syncSlide = true;
                    });
                  },
                ),
              ),
              Container(
                width: 40,
                child: Text(
                  _durationTime,
                  style: themeData.textTheme.subtitle,
                ),
              ),
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  child: FlatButton(
                    splashColor: themeData.primaryColor,
                    highlightColor: themeData.primaryColor,
                    color: themeData.primaryColor,
                    padding: EdgeInsets.only(left: 0, right: 0),
                    child: Icon(
                      Icons.repeat,
                      color: themeData.textTheme.body2.color,
                    ),
                    onPressed: () {
                      widget.hideAction();
                      Navigator.pop(context);
                    },
                  ),
                ),
                _genLastBtn(context),
                SizedBox(
                  width: 10,
                ),
                _genPausePlayBtn(context),
                SizedBox(
                  width: 10,
                ),
                _genNextBtn(context),
                Container(
                  width: 40,
                  height: 40,
                  child: FlatButton(
                    splashColor: themeData.primaryColor,
                    highlightColor: themeData.primaryColor,
                    color: themeData.primaryColor,
                    padding: EdgeInsets.only(left: 0, right: 0),
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
                                size: 30,
                              ),
                            )
                          : Container(
                              key: Key("pause"),
                              child: Icon(
                                CupertinoIcons.heart,
                                color: Colors.red,
                                size: 30,
                              ),
                            ),
                    ),
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
                )
              ],
            ),
            SizedBox(
              height: 30,
            ),
          ]),
        ),
      ),
    );
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
        child: FlatButton(
          splashColor: themeData.primaryColor,
          highlightColor: themeData.primaryColor,
          color: themeData.primaryColor,
          onPressed: () {
            _playPauseAction();
          },
          child: Container(
            key: Key("play"),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeData.textTheme.body2.color,
            ),
            width: 70,
            height: 70,
            child: (_audioPlayerState == AudioPlayerState.PLAYING)
                ? Icon(
                    Icons.pause,
                    size: 40,
                    color: themeData.textTheme.body1.color,
                  )
                : Icon(
                    Icons.play_arrow,
                    size: 40,
                    color: themeData.textTheme.body1.color,
                  ),
          ),
        ));
  }

  _playPauseAction() {
    if (_audioPlayerState == AudioPlayerState.PLAYING) {
      eventBus.fire(MusicPlayEvent(MusicPlayAction.stop));
    } else {
      if (_audioPlayerState == AudioPlayerState.PLAYING) {
//              audioPlayer.pause();
        eventBus.fire(MusicPlayEvent(MusicPlayAction.stop));
      } else if (_audioPlayerState == AudioPlayerState.PAUSED) {
        eventBus.fire(MusicPlayEvent(MusicPlayAction.play));
      } else if (_audioPlayerState == AudioPlayerState.STOPPED) {
      } else if (_audioPlayerState == AudioPlayerState.COMPLETED) {
        eventBus.fire(MusicPlayEvent(MusicPlayAction.play));
        playFile();
      }
    }
  }

  Widget _genLastBtn(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Container(
      child: FlatButton(
        splashColor: themeData.primaryColor,
        highlightColor: themeData.primaryColor,
        color: themeData.primaryColor,
        child: Icon(
          Icons.skip_previous,
          size: 45,
          color: themeData.textTheme.body2.color,
        ),
        onPressed: () {
          playPrev(context);
        },
      ),
    );
  }

  Widget _genNextBtn(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Container(
      child: FlatButton(
        splashColor: themeData.primaryColor,
        highlightColor: themeData.primaryColor,
        color: themeData.primaryColor,
        child: Icon(
          Icons.skip_next,
          size: 45,
          color: themeData.textTheme.body2.color,
        ),
        onPressed: () {
          playNext(context);
        },
      ),
    );
  }

  void playPrev(BuildContext context) {
    var musicInfoData = Provider.of<MusicInfoData>(context, listen: false);
    int newIndex = musicInfoData.playIndex == 0
        ? musicInfoData.musicInfoList.length - 1
        : musicInfoData.playIndex - 1;

    if (newIndex == musicInfoData.playIndex) {
      audioPlayer.seek(Duration(microseconds: 0));
      setState(() => _position = Duration(microseconds: 0));
    }

    Provider.of<MusicInfoData>(context, listen: false).setPlayIndex(newIndex);

    controller.reset();
    controller.forward();
    eventBus.fire(MusicPlayEvent(MusicPlayAction.play));
  }

  void playNext(BuildContext context) {
    var musicInfoData = Provider.of<MusicInfoData>(context, listen: false);
    int newIndex =
        musicInfoData.playIndex < musicInfoData.musicInfoList.length - 1
            ? musicInfoData.playIndex + 1
            : 0;
    if (newIndex == musicInfoData.playIndex) {
      audioPlayer.seek(Duration(microseconds: 0));
      setState(() => _position = Duration(microseconds: 0));
    }

    Provider.of<MusicInfoData>(context, listen: false).setPlayIndex(newIndex);

    controller.reset();
    controller.forward();
    eventBus.fire(MusicPlayEvent(MusicPlayAction.play));
  }
}
