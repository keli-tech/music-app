import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/components/modals/PlayListSelectorContainer.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/models/MusicPlayListModel.dart';
import 'package:hello_world/screens/album/ArtistListDetailScreen.dart';
import 'package:hello_world/screens/album/PlayListDetailScreen.dart';
import 'package:hello_world/services/Database.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../common/RotateTransform.dart';
import '../services/EventBus.dart';

class PlayingScreen extends StatefulWidget {
  PlayingScreen({
    Key? key,
    this.hideAction,
    required this.musicInfoData,
    required this.seekAction,
    required this.audioplayer,
    required this.statusBarHeight,
  }) : super(key: key);

  AudioPlayer audioplayer;
  MusicInfoData musicInfoData;
  double statusBarHeight;

  Future<Null> Function()? hideAction;
  Function(Duration) seekAction;

  @override
  _PlayingScreenState createState() => _PlayingScreenState();
}

class _PlayingScreenState extends State<PlayingScreen>
    with SingleTickerProviderStateMixin {
  // 当前播放进度
  Duration _position = new Duration();

  // 最大进度
  Duration _maxDuration = new Duration(seconds: 1);

  // 当前播放进度 （展示）
  String _currentDurationTime = "";

  // 最大进度（展示）
  String _durationTime = "";

  // 是否同步进度条
  bool _syncSlide = true;

  // 日志
  Logger _logger = new Logger("PlayingScreen");

  // 当前播放 index
  int _playIndex = 0;

  // 动画
  Animation<double>? _animation;

  // 动画控制器
  AnimationController? _animationController;

  // 播放状态
  PlayerState _playerState = new PlayerState(false, ProcessingState.loading);

  // 播放状态事件监听
  var _eventBusOn;

  // 定时器，获取播放进度
  Timer? _periodicTimer;

  @override
  void initState() {
    _logger.info("init state");

    setState(() {
      _playerState = widget.musicInfoData.audioPlayerState;
    });
    _initEvent();
    _initAnimationController();

    syncSlide();
    _periodicTimer = Timer.periodic(new Duration(seconds: 1), (timer) async {
      syncSlide();
    });

    super.initState();
  }

  //销毁
  @override
  void dispose() {
    this._eventBusOn.cancel();
    this._animationController?.dispose();
    this._periodicTimer?.cancel();
    _logger.info("dispose");

    // 触发隐藏行为
    // widget.hideAction();
    super.dispose();
  }

  // 初始化旋转动画
  void _initAnimationController() {
    this._animationController = new AnimationController(
        duration: const Duration(seconds: 30), vsync: this);
    //图片宽高从0变到300
    if (_animationController != null) {
      this._animation =
          new Tween(begin: 0.0, end: 720.0).animate(_animationController!);
    }
    this._animation?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        //动画执行结束时, 继续正像执行动画
        this._animationController?.reset();
        this._animationController?.forward();
      } else if (status == AnimationStatus.dismissed) {
        //动画恢复到初始状态时执行动画（正向）
        this._animationController?.forward();
      }
    });

    if (widget.musicInfoData.audioPlayerState.playing) {
      this._animationController?.forward();
    } else {
      this._animationController?.stop();
    }
  }

  // 初始化监听事件
  void _initEvent() {
    this._eventBusOn = eventBus.on<PlayerStateEvent>().listen((playState) {
      this._logger.info("player state:");
      this._logger.info(playState);

      if (playState.audioPlayerState.playing) {
        this._animationController?.forward();
      } else {
        this._animationController?.stop();
      }
      setState(() {
        _playerState = playState.audioPlayerState;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    final size = MediaQuery.of(context).size;
    final _windowWidth = size.width;
    final _windowHeight = size.height;

    return Stack(
      children: [
        Consumer<MusicInfoData>(
          builder: (context, musicInfoData, _) => AnimatedSwitcher(
            transitionBuilder: (child, anim) {
//                return ScaleTransition(child: child, scale: anim);
              return FadeTransition(
                opacity: anim,
                child: child,
              );
            },
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeOut,
            duration: Duration(milliseconds: 800),
            child: Image(
              key: Key(musicInfoData.musicInfoModel.name.toString()),
              height: _windowHeight,
              fit: BoxFit.cover,
              image: FileManager.musicAlbumPictureImage(
                  musicInfoData.musicInfoModel.artist,
                  musicInfoData.musicInfoModel.album),
            ),
          ),
        ),
        BackdropFilter(
          filter: new ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: new Container(
            color: Colors.black87.withOpacity(0.4),
          ),
        ),
        Container(
          height: _windowHeight,
//            color: themeData.primaryColor,
          child: CupertinoPageScaffold(
            backgroundColor: Colors.transparent,
            child: Consumer<MusicInfoData>(
              builder: (context, musicInfoData, _) =>
                  //顶栏
                  Column(children: <Widget>[
                Expanded(
                  child: Container(
                    width: _windowWidth,
                    height: _windowWidth,
                    child: Hero(
                      tag: "playing",
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Transform.scale(
                              scale: 1.6,
                              child: RotateTransform(
                                animation: _animation!,
                                //将要执行动画的子view
                                child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  pressedOpacity: 1,
                                  color: Colors.transparent,
                                  onPressed: _playPauseAction,
                                  child: CircleAvatar(
                                    backgroundImage: AssetImage(
                                        "assets/images/heijiao-record.png"),
                                    radius: _windowWidth * 0.50,
                                    child: Center(
                                      child: Container(
                                        height: _windowWidth * 0.625,
                                        width: _windowWidth * 0.625,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              _windowWidth * 0.315),
                                          image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: FileManager
                                                  .musicAlbumPictureImage(
                                                      musicInfoData
                                                          .musicInfoModel
                                                          .artist,
                                                      musicInfoData
                                                          .musicInfoModel
                                                          .album)),
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

                // 播放信息
                Text(
                  musicInfoData.musicInfoList.length > 0
                      ? '${musicInfoData.musicInfoList[musicInfoData.playIndex].title} - ${musicInfoData.musicInfoList[musicInfoData.playIndex].artist}'
                      : "",
                  style: themeData.primaryTextTheme.headline5,
                ),
                ListTile(
                  leading: CupertinoButton(
                    onPressed: () {
                      Navigator.pop(context);
//                      widget.hideAction();
                    },
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 30,
                      color: themeData.primaryTextTheme.headline5?.color,
                    ),
                  ),
                  title: Center(
                    child: Text(
                      musicInfoData.musicInfoList.length > 0
                          ? '${musicInfoData.musicInfoList[musicInfoData.playIndex].album}'
                          : "",
                      style: themeData.primaryTextTheme.subtitle1,
                    ),
                  ),
                  trailing: CupertinoButton(
                    onPressed: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context1) {
                          return _actionSheet(context1, context);
                        },
                      );
                    },
                    child: Icon(
                      Icons.more_vert,
                      size: 30,
                      color: themeData.primaryTextTheme.headline5?.color,
                    ),
                  ),
                ),
                // 进度条
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 55,
                        child: Text(
                          _currentDurationTime,
                          style: themeData.primaryTextTheme.subtitle1,
                        ),
                      ),
                      Container(
                        width: _windowWidth - 130,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: new CupertinoSlider(
                          activeColor:
                              themeData.primaryTextTheme.headline5?.color,
                          value: _position.inSeconds.toDouble(),
                          min: 0.0,
                          max: _maxDuration.inSeconds.toDouble(),
                          onChanged: (double value) {
                            Duration curPosition =
                                new Duration(seconds: value.toInt());

                            setState(() {
                              _position = curPosition;
                            });
                          },
                          onChangeStart: (double val) {
                            setState(() {
                              _syncSlide = false;
                            });
                          },
                          onChangeEnd: (double val) {
                            _logger.info("slided:" + val.toInt().toString());
                            Duration curPosition =
                                new Duration(seconds: val.toInt());

                            widget.seekAction(curPosition);
                            // resume()
                            widget.audioplayer.seek(curPosition);
                            // widget.audioplayer.play();
                            setState(() {
//                      _position = curPosition;
                              _syncSlide = true;
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 55,
                        child: Text(
                          _durationTime,
                          style: themeData.primaryTextTheme.subtitle1,
                        ),
                      ),
                    ]),

                // 控制器
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 40,
                      child: CupertinoButton(
                        pressedOpacity: 1,
                        padding: EdgeInsets.zero,
                        child: Icon(
                          Icons.repeat,
                          color: themeData.primaryTextTheme.headline5?.color,
                        ),
                        onPressed: () {
//                          widget.hideAction();
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
                      child: CupertinoButton(
                        pressedOpacity: 1,
                        padding: EdgeInsets.zero,
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
        ),
      ],
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
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          pressedOpacity: 1,
          onPressed: () {
            _playPauseAction();
          },
          child: Container(
            key: Key("play"),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeData.primaryTextTheme.headline5?.color,
            ),
            width: 70,
            height: 70,
            child: (_playerState.playing)
                ? Icon(
                    Icons.pause,
                    size: 40,
                    color: Colors.brown,
                  )
                : Icon(
                    Icons.play_arrow,
                    size: 40,
                    color: Colors.brown,
                  ),
          ),
        ));
  }

  Widget _genLastBtn(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Container(
      child: CupertinoButton(
        pressedOpacity: 1,
        child: Icon(
          Icons.skip_previous,
          size: 45,
          color: themeData.primaryTextTheme.headline5?.color,
        ),
        onPressed: () {
          _playPrev(context);
        },
      ),
    );
  }

  Widget _genNextBtn(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Container(
      child: CupertinoButton(
        pressedOpacity: 1,
        child: Icon(
          Icons.skip_next,
          size: 45,
          color: themeData.primaryTextTheme.headline5?.color,
        ),
        onPressed: () {
          _playNext(context);
        },
      ),
    );
  }

  // 播放和暂停
  _playPauseAction() {
    if (_playerState.playing) {
      eventBus.fire(MusicPlayerEventBus(MusicPlayerEvent.stop));
    } else {
      eventBus.fire(MusicPlayerEventBus(MusicPlayerEvent.play));
    }
  }

  // 上一首
  void _playPrev(BuildContext context) {
    var musicInfoData = Provider.of<MusicInfoData>(context, listen: false);
    int newIndex = musicInfoData.playIndex == 0
        ? musicInfoData.musicInfoList.length - 1
        : musicInfoData.playIndex - 1;

    if (newIndex == musicInfoData.playIndex) {
      widget.audioplayer.seek(Duration(microseconds: 0));
      setState(() => _position = Duration(microseconds: 0));
    }

    Provider.of<MusicInfoData>(context, listen: false).setPlayIndex(newIndex);

    _animationController?.reset();
    _animationController?.forward();
    syncSlide();
    eventBus.fire(MusicPlayerEventBus(MusicPlayerEvent.play));
  }

  // 下一首
  void _playNext(BuildContext context) {
    var musicInfoData = Provider.of<MusicInfoData>(context, listen: false);
    int newIndex =
        musicInfoData.playIndex < musicInfoData.musicInfoList.length - 1
            ? musicInfoData.playIndex + 1
            : 0;
    if (newIndex == musicInfoData.playIndex) {
      widget.audioplayer.seek(Duration(microseconds: 0));
      setState(() => _position = Duration(microseconds: 0));
    }

    Provider.of<MusicInfoData>(context, listen: false).setPlayIndex(newIndex);

    _animationController?.reset();
    _animationController?.forward();
    syncSlide();
    eventBus.fire(MusicPlayerEventBus(MusicPlayerEvent.play));
  }

  // 同步进度条
  void syncSlide() async {
    if (_syncSlide) {
      // 总长度
      var duration = widget.audioplayer.duration;
      if (duration == null) {
        return;
      }
      var d = duration.inMilliseconds;
      // if (d != null) {
      var second = (d / 1000).floor().toInt() % 60;
      String secondStr =
          second < 10 ? "0" + second.toString() : second.toString();
      int minute = (d / 60000).floor().toInt();
      String minuteStr =
          minute < 10 ? "0" + minute.toString() : minute.toString();

      // 当前播放位置
      var position = widget.audioplayer.position;
      var d2 = position.inMilliseconds;
      var second2 = (d2 / 1000).floor().toInt() % 60;
      String secondStr2 =
          second2 < 10 ? "0" + second2.toString() : second2.toString();
      int minute2 = (d2 / 60000).floor().toInt();
      String minuteStr2 =
          minute2 < 10 ? "0" + minute2.toString() : minute2.toString();

      // _logger.info(duration.toString() + "\t" + position.toString());

      if (d2 >= 0) {
        setState(() {
          _maxDuration = duration;
          _durationTime = '$minuteStr:$secondStr';
          _position = position;
          _currentDurationTime = '$minuteStr2:$secondStr2';
        });
        // }
      }
    }
  }

  Widget _actionSheet(BuildContext context1, BuildContext context) {
    ThemeData themeData = Theme.of(context);
    var windowHeight = MediaQuery.of(context).size.height;
    List<Widget> actionSheets = [];
    var musicInfoData = Provider.of<MusicInfoData>(context, listen: false);

    actionSheets.add(CupertinoActionSheetAction(
        child: Text(
          '查看专辑',
        ),
        onPressed: () async {
          Navigator.pop(context1);

          String album = musicInfoData.musicInfoModel.album;
          String artist = musicInfoData.musicInfoModel.artist;

          MusicPlayListModel musicPlayListModel =
              await DBProvider.db.getMusicPlayListByArtistName(artist, album);
          if (musicPlayListModel.getId() > 0) {
            Navigator.of(context, rootNavigator: true)
                .push(MaterialPageRoute<void>(
              builder: (BuildContext context) => PlayListDetailScreen(
                musicPlayListModel: musicPlayListModel,
                statusBarHeight: widget.statusBarHeight,
              ),
            ));
          }
        }));

    actionSheets.add(CupertinoActionSheetAction(
        child: Text(
          '查看歌手',
        ),
        onPressed: () {
          Navigator.pop(context1);

          Navigator.of(context, rootNavigator: true)
              .push(MaterialPageRoute<void>(
            builder: (BuildContext context) => ArtistListDetailScreen(
              artist: musicInfoData.musicInfoModel.artist,
              statusBarHeight: widget.statusBarHeight,
            ),
          ));
        }));

    actionSheets.add(CupertinoActionSheetAction(
      child: Text(
        '收藏到歌单',
      ),
      onPressed: () {
        Navigator.pop(context1);

        showModalBottomSheet<void>(
            context: context,
            useRootNavigator: false,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return PlayListSelectorContainer(
                title: "收藏到歌单",
                mid: musicInfoData.musicInfoModel.id,
                statusBarHeight: widget.statusBarHeight,
              );
            });

//        showCupertinoModalPopup(
//            context: context,
//            builder: (BuildContext context) {
//              return PlayListSelectorContainer(
//                title: "添加到歌单",
//                playListId: mplID,
//                statusBarHeight: statusBarHeight,
//              );
//            });
      },
    ));

    return new CupertinoActionSheet(
      actions: actionSheets,
      cancelButton: CupertinoActionSheetAction(
        child: Text(
          '取消',
        ),
        onPressed: () {
          Navigator.of(context1).pop();
        },
      ),
    );
  }
}
