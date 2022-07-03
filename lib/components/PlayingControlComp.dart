import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/components/Tile.dart';
import 'package:hello_world/components/modals/ModalFit.dart';
import 'package:hello_world/components/modals/MusicFileListComp.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/screens/PlayingScreen.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logging/logging.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import '../services/EventBus.dart';

// 底部播放组件
class PlayingControlComp extends StatefulWidget {
  PlayingControlComp({Key? key, this.showMusicScreen, this.hideAction})
      : super(key: key);

  int? showMusicScreen;

  Future<Null> Function()? hideAction;

  @override
  _PlayingControlCompState createState() => _PlayingControlCompState();
}

class _PlayingControlCompState extends State<PlayingControlComp>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Logger _logger = new Logger("PlayingControlComp");

  // 播放器
  final _player = AudioPlayer();

  // 进度
  Duration _position = new Duration();

  // 最大进度
  Duration _duration = new Duration(seconds: 1);

  // 轮播滑块控制器
  CarouselController _carouselSliderController = CarouselController();

  // 播放状态
  PlayerState _playerState = new PlayerState(false, ProcessingState.loading);

  // 播放列表
  ConcatenatingAudioSource _playList = ConcatenatingAudioSource(
    useLazyPreparation: true,
    shuffleOrder: DefaultShuffleOrder(),
    children: [],
  );

  // 播放原始列表
  List<MusicInfoModel> musicInfoModelList = [];

  // 播放 index
  int playIndex = 0;

  // 当前播放信息
  MusicInfoModel musicInfoModel = new MusicInfoModel(
    name: "",
    path: "",
    fullpath: "",
    type: "",
    syncstatus: true,
  );

  // 动画
  Animation<double>? animation;

  // 动画控制器
  AnimationController? animationController;

  // 播放核心监听
  var _playerEventListener;

  // 播放器监听
  var _musicplayerEventListener;

  @override
  void initState() {
    super.initState();

    _logger.info("initState!");
    _initPlayer();
    _initEvent();
    _initMusicPlayerEvent();
    _initAnimationController();
  }

  // 初始化播放器
  void _initPlayer() {
    _logger.info("player init event:");

    // 监听播放状态变更
    _player.playerStateStream.listen((event) {
      return;
      _logger.info("playerStateStream：");
      _logger.info(event);

      if (event.playing == false &&
          event.processingState == ProcessingState.completed) {
        _logger.info("播放下一首");
        _playNext(context);
      }

      return;
    });

    //
    _player.playbackEventStream.listen((event) {
      // _logger.info(event);
      // return;
      if (event.duration == null) {
        return;
      }
      // _logger.info("_initPlayer:");
      // _logger.info(event);
      // var d = event.duration;
      // var second = d.inSeconds % 60;
      // String secondStr =
      //     second < 10 ? "0" + second.toString() : second.toString();
      // int minute = (d.inSeconds.toInt() / 60).round().toInt();
      // String minuteStr =
      //     minute < 10 ? "0" + minute.toString() : minute.toString();
      // _logger.info(minuteStr);
      // _logger.info(secondStr);
      // setState(() {
      //   _duration = d;
      // });
    });

    // 监听播放状态变化
    _player.playingStream.listen((bool playintEvent) {
      if (playintEvent) {
        var ps = new PlayerState(true, ProcessingState.completed);
        eventBus.fire(PlayerStateEvent(ps));
      } else {
        var ps = new PlayerState(false, ProcessingState.ready);
        eventBus.fire(PlayerStateEvent(ps));
      }
    });

    // audioPlayer.onPlayerCommand.listen((onData) {
    //   if (onData == PlayerControlCommand.NEXT_TRACK) {
    //     _playNext(context);
    //   } else if (onData == PlayerControlCommand.PREVIOUS_TRACK) {
    //     _playPrevious(context);
    //   } else {
    //     _logger.warning("onPlayerCommand" + onData.toString());
    //   }
    // });

    // 获取当前播放位置
    _player.durationStream.listen((Duration? d) {
      _logger.info(d);
      if ((_position.inSeconds.toInt() - d!.inSeconds.toInt()).abs() <= 2) {
        var second = d.inSeconds % 60;
        String secondStr =
            second < 10 ? "0" + second.toString() : second.toString();
        int minute = (d.inSeconds.toInt() / 60).round().toInt();
        String minuteStr =
            minute < 10 ? "0" + minute.toString() : minute.toString();
        // setState(() {
        //   _position = d;
        // });
      }
    });

    // 播放完成
    // _player.onPlayerComplete.listen((onData) {
    // _playNext(context);
    // });
  }

  // 初始化监听事件
  void _initEvent() {
    _logger.info("audio player event init event:");

    _playerEventListener = eventBus.on<PlayerStateEvent>().listen((event) {
      _logger.info("audio player event:" + event.audioPlayerState.toString());
      // if (_playerState != event.audioPlayerState) {
      _playerState = event.audioPlayerState;

      Provider.of<MusicInfoData>(context, listen: false)
          .setAudioPlayerState(event.audioPlayerState);
      // }
    });
  }

  void _initMusicPlayerEvent() {
    _logger.info("music player event init:");

    _musicplayerEventListener =
        eventBus.on<MusicPlayerEventBus>().listen((event) async {
      _logger.info("music player event:" + event.musicPlayerEvent.toString());

      // 获取全局播放信息
      var musicInfoData = Provider.of<MusicInfoData>(context, listen: false);

      if (event.musicPlayerEvent == MusicPlayerEvent.play) {
        // 播放初始化 列表
        if (musicInfoData != null) {
          List<UriAudioSource> audioSourceList = [];

          musicInfoData.musicInfoList.forEach((element) {
            var file = FileManager.musicFilePath(element.fullpath);
            audioSourceList.add(AudioSource.uri(Uri.parse("file://" + file)));
          });
          if (musicInfoData.musicInfoList.length <= 0) {
            return;
          }

          var newPlayIndex = musicInfoData.playIndex;
          _logger.info("playIndex: " + newPlayIndex.toString());

          _playList = ConcatenatingAudioSource(
            useLazyPreparation: true,
            shuffleOrder: DefaultShuffleOrder(),
            children: audioSourceList,
          );

          await this._player.setAudioSource(_playList);
          try {
            // todo 如果切换了播放列表需要处理
            if (newPlayIndex == playIndex) {
              this._player.play();

              return;
            }

            if (event.musicPlayerEvent == MusicPlayerEvent.play) {
              // 通过滑动切换到下一首
              _carouselSliderController.jumpToPage(newPlayIndex);
              await this._player.play();
            }
          } catch (error) {
            print(error);
          }
        }
      } else if (event.musicPlayerEvent == MusicPlayerEvent.scroll_play) {
        // 滑动播放上一首、下一首
        var newPlayIndex = musicInfoData.playIndex;
        if (playIndex != newPlayIndex) {
          try {} catch (error) {
            print(error);
          }
        }
        await this._player.seek(Duration.zero, index: newPlayIndex);
        playIndex = newPlayIndex;
        animationController?.forward();
      } else if (event.musicPlayerEvent == MusicPlayerEvent.stop) {
        _player.pause();
      } else if (event.musicPlayerEvent == MusicPlayerEvent.last) {
      } else if (event.musicPlayerEvent == MusicPlayerEvent.next) {}
    });
  }

  //销毁
  @override
  void dispose() {
    this._playerEventListener.cancel();
    this._musicplayerEventListener.cancel();
    _player.stop();
    _player.dispose();
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
    animationController = new AnimationController(
        duration: const Duration(seconds: 30), vsync: this);
    if (animationController != null) {
      animation =
          new Tween(begin: 0.0, end: 720.0).animate(animationController!);
    }
    animation?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController?.reset();

        animationController?.forward();
      } else if (status == AnimationStatus.dismissed) {
        animationController?.forward();
      }
    });

    //启动动画（正向）
    animationController?.stop();
  }

  Future playFile() async {
    if (musicInfoModel == null || musicInfoModel.name == "") {
      return;
    }

    // 推送通知

    // audioPlayer
    //     .setNotification(
    //       title: musicInfoModel.title,
    //       artist: musicInfoModel.artist,
    //       albumTitle: musicInfoModel.album,
    //       hasNextTrack: true,
    //       hasPreviousTrack: true,
    //       duration: _duration,
    //       imageUrl: FileManager.musicAlbumPictureFullPath(
    //               musicInfoModel.artist, musicInfoModel.album)
    //           .path,
    //     )
    //     .then((v) {})
    //     .catchError((e) {
    //   print('error with setNotification $e');
    // });
  }

  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    var mq = MediaQuery.of(context);

    double _statusBarHeight = mq.padding.top;
    double _windowHeight = mq.size.height;
    double _windowWidth = mq.size.width;
    double _bottomBarHeight = mq.padding.bottom;

    _logger.info("rebuild playing controller comp");
    var initPlayIndex = 0;

    var initListLength = 4;
    _logger.info(initPlayIndex);
    _logger.info(initListLength);

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
                  offset: Offset(0.0, -4.0),
                  blurRadius: 1.0,
                  spreadRadius: 0.30,
                ),
                BoxShadow(
                  color: Color(0x6aFFFFFF),
                  // 向上阴影
                  offset: Offset(0.0, -12.0),
                  blurRadius: 20.0,
                  spreadRadius: 2.0,
                ),
                BoxShadow(
                  color: Color(0x6aFFFFFF),
                  offset: Offset(10.0, 0.0),
                  blurRadius: 15.0,
                  spreadRadius: 2.0,
                ),
                BoxShadow(
                  color: Color(0x6aFFFFFF),
                  // 向上阴影
                  offset: Offset(-10.0, 0.0),
                  blurRadius: 15.0,
                  spreadRadius: 2.0,
                ),
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
                      _playerState.playing
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      size: 35,
                      color: themeData.primaryColorDark,
                    ),
                  ),
                  onPressed: () {
                    if (_playerState.playing) {
                      eventBus.fire(MusicPlayerEventBus(MusicPlayerEvent.stop));
                    } else {
                      eventBus.fire(MusicPlayerEventBus(MusicPlayerEvent.play));
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
                            : CarouselSlider(
                                carouselController: _carouselSliderController,
                                options: CarouselOptions(
                                    autoPlay: false,
                                    height: 45.0,
                                    viewportFraction: 1.0,
                                    initialPage: initPlayIndex,
                                    onPageChanged: (index, onValue) {
                                      _logger.info(
                                          "carouse slider changed $index");
                                      // 播放 Next
                                      Provider.of<MusicInfoData>(context,
                                              listen: false)
                                          .setPlayIndex(index);
                                      // 通知开始播放 Play
                                      eventBus.fire(MusicPlayerEventBus(
                                          MusicPlayerEvent.scroll_play));
                                    }),
                                items: musicInfoData.musicInfoList
                                    .map((musicInfoModel) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              musicInfoModel.title,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color:
                                                    themeData.primaryColorLight,
                                              ),
                                            ),
                                            Text(
                                              musicInfoModel.artist,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color:
                                                    themeData.primaryColorLight,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ))
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
                                )),
                      onPressed: () {
//                          _buttonCarouselController.nextPage(
//                              duration: Duration(milliseconds: 300),
//                              curve: Curves.linear);

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
                        showModalBottomSheet<void>(
                            elevation: 15,
                            context: context,
                            useRootNavigator: true,
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return MusicFileListComp(
                                statusBarHeight: 0,
                              );
                            });
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

            showModalBottomSheet<void>(
                context: context,
                useRootNavigator: false,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return PlayingScreen(
                    hideAction: widget.hideAction,
                    seekAction: seek,
                    audioplayer: _player,
                    musicInfoData: musicInfoData,
                    statusBarHeight: _statusBarHeight,
                  );
                });
          },
        )),
      ),
    );
  }

  // 滑动播放信息组件
  Widget buildCarouselControl(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Consumer<MusicInfoData>(
        builder: (context, musicInfoData, _) => CarouselSlider(
              carouselController: _carouselSliderController,
              options: CarouselOptions(
                  autoPlay: false,
                  height: 45.0,
                  viewportFraction: 1.0,
                  initialPage: musicInfoData.playIndex >
                          musicInfoData.musicInfoList.length - 1
                      ? musicInfoData.musicInfoList.length - 1
                      : musicInfoData.playIndex,
                  onPageChanged: (index, onValue) {
                    _logger.info("carouse slider changed $index");
                    // 播放 Next
                    Provider.of<MusicInfoData>(context, listen: false)
                        .setPlayIndex(index);
                    // 通知开始播放 Play
                    eventBus.fire(
                        MusicPlayerEventBus(MusicPlayerEvent.scroll_play));
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
            ));
  }

  // 播放下一首
  void _playNext(BuildContext context) {
    var musicInfoData = Provider.of<MusicInfoData>(context, listen: false);
    int newIndex =
        musicInfoData.playIndex < musicInfoData.musicInfoList.length - 1
            ? musicInfoData.playIndex + 1
            : 0;
    if (newIndex == musicInfoData.playIndex) {
      _player.seek(Duration(microseconds: 0));
      setState(() => _position = Duration(microseconds: 0));
    }

    Provider.of<MusicInfoData>(context, listen: false).setPlayIndex(newIndex);

    animationController?.reset();
    animationController?.forward();
    eventBus.fire(MusicPlayerEventBus(MusicPlayerEvent.play));
  }

  // 播放上一首
  void _playPrevious(BuildContext context) {
    var musicInfoData = Provider.of<MusicInfoData>(context, listen: false);
    int newIndex = musicInfoData.playIndex == 0
        ? musicInfoData.musicInfoList.length - 1
        : musicInfoData.playIndex - 1;
    if (newIndex == musicInfoData.playIndex) {
      _player.seek(Duration(microseconds: 0));
      setState(() => _position = Duration(microseconds: 0));
    }

    Provider.of<MusicInfoData>(context, listen: false).setPlayIndex(newIndex);

    animationController?.reset();
    animationController?.forward();
    eventBus.fire(MusicPlayerEventBus(MusicPlayerEvent.play));
  }

  // 指定位置开始播放
  void seek(Duration position) {
    _logger.info(position);
    _player.seek(position);
  }
}
