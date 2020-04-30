import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/components/Tile.dart';
import 'package:hello_world/components/modals/MusicFileListComp.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/screens/PlayingScreen.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:logging/logging.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
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
  CarouselController _buttonCarouselController = CarouselController();

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

  static List<int> playIndexStack = [];

  Animation<double> animation;
  AnimationController controller;

  static AudioPlayer audioPlayer;
  var _eventBusOn;
  var _musicplayerEvent;

  @override
  void initState() {
    super.initState();

    _logger.info("initState!");
    _initPlayer();
    _initEvent();
    _initMusicPlayerEvent();
    _initAnimationController();
  }

  void _initMusicPlayerEvent() {
    _musicplayerEvent = eventBus.on<MusicPlayerEventBus>().listen((event) {
      _logger.info(event.musicPlayerEvent);

      if (event.musicPlayerEvent == MusicPlayerEvent.show_player) {
        var musicInfoData = Provider.of<MusicInfoData>(context, listen: false);

        _showPlayer(musicInfoData);
      }

      var musicInfoData = Provider.of<MusicInfoData>(context, listen: false);
      if (event.musicPlayerEvent == MusicPlayerEvent.play ||
          event.musicPlayerEvent == MusicPlayerEvent.scroll_play) {
        if (musicInfoData != null) {
          if (musicInfoModel !=
                  musicInfoData.musicInfoList[musicInfoData.playIndex] &&
              musicInfoData.musicInfoList[musicInfoData.playIndex].name != "") {
            musicInfoModel =
                musicInfoData.musicInfoList[musicInfoData.playIndex];

            _position = new Duration(seconds: 0);
            playFile();

            try {
              if (event.musicPlayerEvent == MusicPlayerEvent.play) {
                _buttonCarouselController.jumpToPage(musicInfoData.playIndex);
              }
            } catch (error) {
              print(error);
            }

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
        _playPrevious(context);
      } else if (event.musicPlayerEvent == MusicPlayerEvent.next) {
        _playNext(context, false);
      }
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
      if (_musicPlayAction != event.audioPlayerState) {
        _musicPlayAction = event.audioPlayerState;

        Provider.of<MusicInfoData>(context, listen: false)
            .setAudioPlayerState(event.audioPlayerState);
      }
    });
  }

  void _initPlayer() {
    audioPlayer = new AudioPlayer();

    audioPlayer.onPlayerCommand.listen((onData) {
      if (onData == PlayerControlCommand.NEXT_TRACK) {
        _playNext(context, false);
      } else if (onData == PlayerControlCommand.PREVIOUS_TRACK) {
        _playPrevious(context);
      } else {
        _logger.warning("onPlayerCommand" + onData.toString());
      }
    });

    // 获取音乐时长
    audioPlayer.onDurationChanged.listen((Duration d) {
      var second = d.inSeconds % 60;
      String secondStr =
          second < 10 ? "0" + second.toString() : second.toString();
      int minute = (d.inSeconds.toInt() / 60).round().toInt();
      String minuteStr =
          minute < 10 ? "0" + minute.toString() : minute.toString();

      setState(() {
        _duration = d;
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
        setState(() {
          _position = d;
        });
      }
    });

    // 监听播放状态变化
    audioPlayer.onPlayerStateChanged.listen((AudioPlayerState aps) {
      eventBus.fire(AudioPlayerEvent(aps));
    });

    audioPlayer.onPlayerCompletion.listen((onData) {
      _playNext(context, true);
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

    audioPlayer
        .setNotification(
          title: musicInfoModel.title,
          artist: musicInfoModel.artist,
          albumTitle: musicInfoModel.album,
          hasNextTrack: true,
          hasPreviousTrack: true,
          duration: _duration,
          imageUrl: FileManager.musicAlbumPictureFullPath(
                  musicInfoModel.artist, musicInfoModel.album)
              .path,
        )
        .then((v) {})
        .catchError((e) {
      print('error with setNotification $e');
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
          child: new FlatButton(
            padding: EdgeInsets.zero,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: themeData.primaryColorLight,
                    // 向上阴影
                    offset: Offset(0.0, -1.0),
                    blurRadius: 1.0,
                    spreadRadius: 0.30,
                  ),
//                  BoxShadow(
//                    color: Color(0x6aFFFFFF),
//                    // 向上阴影
//                    offset: Offset(0.0, -12.0),
//                    blurRadius: 20.0,
//                    spreadRadius: 2.0,
//                  ),
//                  BoxShadow(
//                    color: Color(0x6aFFFFFF),
//                    offset: Offset(10.0, 0.0),
//                    blurRadius: 15.0,
//                    spreadRadius: 2.0,
//                  ),
//                  BoxShadow(
//                    color: Color(0x6aFFFFFF),
//                    // 向上阴影
//                    offset: Offset(-10.0, 0.0),
//                    blurRadius: 15.0,
//                    spreadRadius: 2.0,
//                  ),
                ],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0)),
                color: themeData.primaryColorDark,
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 80,
                  height: 50,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    pressedOpacity: 1,
                    child: Tile(
                      selected: false,
                      radiusnum: 50,
                      blur: 4,
                      child: Icon(
                        _musicPlayAction == AudioPlayerState.PLAYING
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        size: 35,
                        color: themeData.primaryColorDark,
                      ),
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
                  height: 40,
                  width: 100,
                  child: Row(
                    children: <Widget>[
                      CupertinoButton(
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
                                    child: Transform.scale(
                                      scale: 1.4,
                                      child: Lottie.asset(
                                        'assets/lf20_3ngy1x.json',
                                        repeat: false,
                                        animate: true,
                                        reverse: false,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  )
                                : Container(
                                    key: Key("pause"),
                                    child: Icon(
                                      CupertinoIcons.heart,
                                      color: Colors.red,
                                      size: 32,
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
                      CupertinoButton(
                        onPressed: () {
                          _showMusicFileListComp(context);
                        },
                        padding: EdgeInsets.zero,
                        child: Icon(
                          Icons.format_list_bulleted,
                          color: themeData.primaryColorLight,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            onPressed: () {
              if (musicInfoData.playIndex == null ||
                  musicInfoData.playIndex < 0 ||
                  musicInfoData.musicInfoList == null ||
                  musicInfoData.musicInfoList.length <= 0) {
                return;
              }

              _showPlayer(musicInfoData);
            },
          ),
        ),
      ),
    );
  }

  Widget buildCarouselControl(
      BuildContext context, MusicInfoData musicInfoData) {
    ThemeData themeData = Theme.of(context);

    _carouselControl = CarouselSlider(
      carouselController: _buttonCarouselController,
      options: CarouselOptions(
          autoPlay: false,
          height: 45.0,
          viewportFraction: 1.0,
          initialPage:
              musicInfoData.playIndex > musicInfoData.musicInfoList.length - 1
                  ? musicInfoData.musicInfoList.length - 1
                  : musicInfoData.playIndex,
          onPageChanged: (index, onValue) {
            _logger.info("carouse slider changed $index");
            // 播放 Next
            Provider.of<MusicInfoData>(context, listen: false)
                .setPlayIndex(index);
            // 通知开始播放 Play
            eventBus.fire(MusicPlayerEventBus(MusicPlayerEvent.scroll_play));
          }),
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
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 13,
                      color: themeData.primaryColorLight,
                    ),
                  ),
                  Text(
                    musicInfoModel.artist,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 10,
                      color: themeData.primaryColorLight,
                    ),
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

  // 上一首
  void _playPrevious(BuildContext context) {
    var musicInfoData = Provider.of<MusicInfoData>(context, listen: false);

    int oldIndex = musicInfoData.playIndex;
    // 顺序 new index
    int newIndex = musicInfoData.playIndex == 0
        ? musicInfoData.musicInfoList.length - 1
        : musicInfoData.playIndex - 1;
    PlayMode playMode = musicInfoData.playMode;
    if (playMode == PlayMode.repeat) {
      // 随机模式的， 上一首 和顺序的一致；
      // do nothing
    } else if (playMode == PlayMode.order) {
      // 顺序 new index
      // do nothing
    } else if (playMode == PlayMode.shuffle) {
      if (playIndexStack.length > 0) {
        newIndex = playIndexStack.removeLast();
      } else {
        // 没有则和顺序一致；
      }
    }
    // 播放上一首，不增加到 stack 中；

    if (newIndex == musicInfoData.playIndex) {
      audioPlayer.seek(Duration(microseconds: 0));
      setState(() => _position = Duration(microseconds: 0));
    }

    Provider.of<MusicInfoData>(context, listen: false).setPlayIndex(newIndex);
    controller.reset();
    controller.forward();
    eventBus.fire(MusicPlayerEventBus(MusicPlayerEvent.play));
  }

  void _playNext(BuildContext context, bool completed) {
    var musicInfoData = Provider.of<MusicInfoData>(context, listen: false);

    int oldIndex = musicInfoData.playIndex;
    int newIndex =
        musicInfoData.playIndex < musicInfoData.musicInfoList.length - 1
            ? musicInfoData.playIndex + 1
            : 0;
    PlayMode playMode = musicInfoData.playMode;
    if (playMode == PlayMode.repeat) {
      if (completed) {
        newIndex = oldIndex;
      } else {
        // do nothing
      }
    } else if (playMode == PlayMode.order) {
      // do nothing
    } else if (playMode == PlayMode.shuffle) {
      int length = musicInfoData.musicInfoList.length;
      Set<int> allSet = {};
      for (int i = 0; i < length; i++) {
        allSet.add(i);
      }
      Set<int> remindSet = allSet.difference(playIndexStack.toSet());
      if (remindSet.length <= 1) {
        // 全部播放一遍了，则清除，重新来；
        playIndexStack.clear();
        remindSet = allSet.difference(playIndexStack.toSet());
      }

      var rr = Random(new DateTime.now().millisecondsSinceEpoch);
      int ind = rr.nextInt(remindSet.length);
      newIndex = remindSet.toList().getRange(ind - 1, ind).first;
    }
    // 添加记录.
    playIndexStack.add(oldIndex);

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
    audioPlayer.seek(position);
  }

  _showMusicFileListComp(BuildContext context) {
    showCupertinoModalBottomSheet(
      expand: true,
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context, scrollController) => Material(
        color: Color(0xffececec),
        child: SafeArea(
          top: false,
          child: MusicFileListComp(
            colorReverse: true,
          ),
        ),
      ),
    );
  }

  _showPlayer(MusicInfoData musicInfoData) {
    showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return PlayingScreen(
            hideAction: widget.hideAction,
            seekAction: seek,
            audioplayer: audioPlayer,
            musicInfoData: musicInfoData,
          );
        });
  }
}
