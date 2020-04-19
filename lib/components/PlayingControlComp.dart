import 'package:audioplayers/audioplayers.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/screens/PlayingScreen.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../services/EventBus.dart';

class PlayingControlComp extends StatefulWidget {
  PlayingControlComp(
      {Key key, this.title, this.showMusicScreen, this.hideAction})
      : super(key: key);

  final String title;
  int showMusicScreen;

  Future<Null> Function() hideAction;

  @override
  _PlayingControlCompState createState() => _PlayingControlCompState();
}

class _PlayingControlCompState extends State<PlayingControlComp>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Logger _logger = new Logger("PlayingControlComp");

  Duration _position = new Duration();
  Duration _duration = new Duration(seconds: 1);
  CarouselSlider _carouselControl;
  String _currentDurationTime = "";
  String _durationTime = "";
  AudioPlayerState _musicPlayAction = AudioPlayerState.STOPPED;

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

  static AudioPlayer audioPlayer;
  var _eventBusOn;
  var _musicplayerEvent;

  @override
  void initState() {
    super.initState();

    _logger.info("init");
    _initPlayer();
    _initEvent();
    _initMusicPlayerEvent();
    _initAnimationController();
  }

  void _initMusicPlayerEvent() {
    _musicplayerEvent = eventBus.on<MusicPlayerEventBus>().listen((event) {
      _logger.info(event.musicPlayerEvent);

      var musicInfoData = Provider.of<MusicInfoData>(context, listen: false);
      if (event.musicPlayerEvent == MusicPlayerEvent.play) {
        if (musicInfoData != null) {
          if (musicInfoModel !=
                  musicInfoData.musicInfoList[musicInfoData.playIndex] &&
              musicInfoData.musicInfoList[musicInfoData.playIndex].name != "") {
            musicInfoModel =
                musicInfoData.musicInfoList[musicInfoData.playIndex];

            _position = new Duration(seconds: 0);
            playFile();

            _carouselControl.jumpToPage(musicInfoData.playIndex);

            audioPlayer.resume();
            controller.forward();
          } else {
            audioPlayer.resume();
            controller.forward();
          }
        }
      } else if (event.musicPlayerEvent == MusicPlayerEvent.stop) {
        audioPlayer.pause();
      } else if (event.musicPlayerEvent == MusicPlayerEvent.last) {
      } else if (event.musicPlayerEvent == MusicPlayerEvent.next) {}
    });
  }

  //销毁
  @override
  void dispose() {
    this._eventBusOn.cancel();
    this._musicplayerEvent.cancel();
    audioPlayer.stop();
    audioPlayer.dispose();
    _logger.info("play screen disposed!!");
    super.dispose();
  }

  @override
  void deactivate() {
    _logger.info("play screen deactivate!!");
    super.deactivate();
  }

  // 初始化旋转动画
  void _initAnimationController() {
    controller = new AnimationController(
        duration: const Duration(seconds: 30), vsync: this);
    animation = new Tween(begin: 0.0, end: 720.0).animate(controller);
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reset();

        controller.forward();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });

    //启动动画（正向）
    controller.stop();
  }

  // 初始化监听事件
  void _initEvent() {
    _eventBusOn = eventBus.on<AudioPlayerEvent>().listen((event) {
      _logger.info("audio player event:" + event.audioPlayerState.toString());

      if (_musicPlayAction != event.audioPlayerState) {
        _musicPlayAction = event.audioPlayerState;

        Provider.of<MusicInfoData>(context, listen: false)
            .setAudioPlayerState(event.audioPlayerState);
      }
    });
  }

  void _initPlayer() {
    audioPlayer = new AudioPlayer();

    audioPlayer.monitorNotificationStateChanges((callback) {
      _logger.info(callback);
    });

    // 获取音乐时长
    audioPlayer.onDurationChanged.listen((Duration d) {
      var second = d.inSeconds % 60;
      String secondStr =
          second < 10 ? "0" + second.toString() : second.toString();
      int minute = (d.inSeconds.toInt() / 60).round().toInt();
      String minuteStr =
          minute < 10 ? "0" + minute.toString() : minute.toString();
      print('total: $minuteStr:$secondStr');

      setState(() {
        _duration = d;
        _durationTime = '$minuteStr:$secondStr';
      });
    });

    // 获取当前播放位置
    audioPlayer.onAudioPositionChanged.listen((Duration d) {
      if ((_position.inSeconds.toInt() - d.inSeconds.toInt()).abs() <= 2) {
        var second = d.inSeconds % 60;
        String secondStr =
            second < 10 ? "0" + second.toString() : second.toString();
        int minute = (d.inSeconds.toInt() / 60).round().toInt();
        String minuteStr =
            minute < 10 ? "0" + minute.toString() : minute.toString();
//        print('current: $minuteStr:$secondStr');
        setState(() {
          _position = d;
          _currentDurationTime = '$minuteStr:$secondStr';
        });
      }
    });

    // 监听播放状态变化
    audioPlayer.onPlayerStateChanged.listen((AudioPlayerState aps) {
      eventBus.fire(AudioPlayerEvent(aps));
    });

    audioPlayer.onPlayerCompletion.listen((onData) {
      playNext(context);
    });
  }

  Future playFile() async {
    if (musicInfoModel == null || musicInfoModel.name == "") {
      return;
    }

    var file = FileManager.musicFilePath(musicInfoModel.fullpath);
    // fixme
//    audioPlayer.setUrl(file, isLocal: true);
    audioPlayer.play(file, isLocal: true);

    _logger.warning(FileManager.musicAlbumPictureFullPath(
            musicInfoModel.artist, musicInfoModel.album)
        .path);

    audioPlayer
        .setNotification(
      title: musicInfoModel.title,
      artist: musicInfoModel.artist,
      albumTitle: musicInfoModel.album,
      duration: _duration,
//      imageUrl: 'http://p2.music.126.net/VA3kAvrg2YRrxCgDMJzHnw==/3265549618941178.jpg',
      imageUrl: FileManager.musicAlbumPictureFullPath(
              musicInfoModel.artist, musicInfoModel.album)
          .path,
    )
        .then((v) {
      print('Notification ok');
    }).catchError((e) {
      print('error with setNotification $e');
    });

    setState(() {
//      _musicPlayAction = AudioPlayerState.PLAYING;
    });
  }

  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    var mq = MediaQuery.of(context);

    double _statusBarHeight = mq.padding.top;
    double _windowHeight = mq.size.height;
    double _windowWidth = mq.size.width;
    double _bottomBarHeight = mq.padding.bottom;

    return Positioned(
      width: MediaQuery.of(context).size.width,
      bottom: 50 + _bottomBarHeight,
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
                      _musicPlayAction == AudioPlayerState.PLAYING
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      size: 35,
                      semanticLabel: 'Add',
                    ),
                    onPressed: () {
                      if (_musicPlayAction == AudioPlayerState.PLAYING) {
                        eventBus
                            .fire(MusicPlayerEventBus(MusicPlayerEvent.stop));
                      } else {
                        eventBus
                            .fire(MusicPlayerEventBus(MusicPlayerEvent.play));
                      }
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

                Navigator.of(context, rootNavigator: true)
                    .push(CupertinoPageRoute<void>(
                  title: "",
                  fullscreenDialog: true,
                  builder: (BuildContext context) => PlayingScreen(
                    hideAction: widget.hideAction,
                    seekAction: seek,
                    audioplayer: audioPlayer,
                    musicInfoData: musicInfoData,
                  ),
                ));
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
        // 播放 Next
        Provider.of<MusicInfoData>(context, listen: false)
            .setPlayIndex(onValue);
        // 通知开始播放 Play
        eventBus.fire(MusicPlayerEventBus(MusicPlayerEvent.play));
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
    eventBus.fire(MusicPlayerEventBus(MusicPlayerEvent.play));
  }

  void seek(Duration position) {
    print(position);

    audioPlayer.seek(position);
  }
}
