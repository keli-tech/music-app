import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:provider/provider.dart';

import '../common/RotateTransform.dart';
import '../models/MusicInfoModel.dart';
import '../services/Database.dart';
import '../services/EventBus.dart';
import 'MyHttpServer.dart';

class MusicFavListScreen extends StatefulWidget {
  @override
  _MusicFavListScreen createState() => _MusicFavListScreen();
}

class _MusicFavListScreen extends State<MusicFavListScreen>
    with SingleTickerProviderStateMixin {
  List<MusicInfoModel> _musicInfoModels = [];
  TextEditingController _chatTextController = TextEditingController();
  Animation<double> animation;
  AnimationController controller;

  var _eventBusOn;
  bool _isLoding = false;

  @override
  void initState() {
    super.initState();

    _refreshList();

    controller = new AnimationController(
        duration: const Duration(seconds: 10), vsync: this);
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

    _eventBusOn = eventBus.on<MusicPlayEvent>().listen((event) {
      if (event.musicPlayAction == MusicPlayAction.play) {
        controller.forward();
      } else if (event.musicPlayAction == MusicPlayAction.stop) {
        controller.stop();
      }
      setState(() {});
    });
  }

  //销毁
  @override
  void dispose() {
    this._eventBusOn.cancel();

    print("play screen disposed!!");
    super.dispose();
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);

    _refreshList();
  }

  _refreshList() async {
    DBProvider.db.getFavMusicInfoList().then((onValue) {
      // 红心 ID Set
      Set<int> musicInfoFavIDSet = onValue.map((f) {
        return f.id;
      }).toSet();
      Provider.of<MusicInfoData>(context, listen: false)
          .setMusicInfoFavIDSet(musicInfoFavIDSet);

      setState(() {
        _musicInfoModels = onValue;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    var musicInfoData = Provider.of<MusicInfoData>(context, listen: false);

    return Container(
      color: themeData.backgroundColor,
      child: CupertinoPageScaffold(
        backgroundColor: themeData.backgroundColor,
        child: RefreshIndicator(
          color: Colors.white,
          backgroundColor: themeData.primaryColor,
          child: CustomScrollView(
            semanticChildCount: _musicInfoModels.length,
            slivers: <Widget>[
              CupertinoSliverNavigationBar(
                backgroundColor: themeData.backgroundColor,
                largeTitle: Text(
                  "红心",
                  style: themeData.primaryTextTheme.headline,
                ),
//                backgroundColor: themeData.backgroundColor,
              ),
              Consumer<MusicInfoData>(
                builder: (context, musicInfoData, _) => SliverPadding(
                  // Top media padding consumed by CupertinoSliverNavigationBar.
                  // Left/Right media padding consumed by Tab1RowItem.
                  padding:
                      EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 70),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return Tab1RowItem(
                          index: index,
                          lastItem: index == _musicInfoModels.length - 1,
                          musicInfoModels: _musicInfoModels,
                          playId: musicInfoData.musicInfoModel.id,
                          musicInfoFavIDSet: musicInfoData.musicInfoFavIDSet,
                          animation: animation,
                          controller: controller,
                        );
                      },
                      childCount: _musicInfoModels.length,
                    ),
                  ),
                ),
              ),
            ],
          ),
          onRefresh: () {
            if (_isLoding) return null;
            setState(() {
              _isLoding = true;
            });
            return _refreshList().then((value) {
              print('success');
              setState(() {
                _isLoding = false;
              });
            }).catchError((error) {
              print('failed');
            });
          },
        ),
      ),
    );
  }
}

class Tab1RowItem extends StatelessWidget {
  const Tab1RowItem(
      {this.index,
      this.lastItem,
      this.musicInfoModels,
      this.playId,
      this.musicInfoFavIDSet,
      this.animation,
      this.controller});

  final int index;
  final bool lastItem;
  final List<MusicInfoModel> musicInfoModels;
  final int playId;
  final Set<int> musicInfoFavIDSet;

  final Animation<double> animation;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    MusicInfoModel _musicInfoModel = musicInfoModels[index];
    List<MusicInfoModel> mims =
        musicInfoModels.getRange(0, musicInfoModels.length).toList();
    mims.removeWhere((music) {
      return music.type == "fold";
    });
    int offset = musicInfoModels.length - mims.length;

    final Widget row = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // todo 2 to 1

        Provider.of<MusicInfoData>(context, listen: false)
            .setMusicInfoList(mims);
        Provider.of<MusicInfoData>(context, listen: false)
            .setPlayIndex(index - offset);

        controller.reset();

        controller.forward();
        eventBus.fire(MusicPlayEvent(MusicPlayAction.play));
      },
      child: Container(
        color: themeData.backgroundColor,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(
                left: 16.0, top: 8.0, bottom: 8.0, right: 8.0),
            child: Row(
              children: <Widget>[
                AnimatedSwitcher(
                  transitionBuilder: (child, anim) {
                    return ScaleTransition(child: child, scale: anim);
                  },
                  switchInCurve: Curves.fastLinearToSlowEaseIn,
                  switchOutCurve: Curves.fastOutSlowIn,
                  duration: Duration(milliseconds: 300),
                  child: playId == musicInfoModels[index].id
                      ? RotateTransform(
                          animation: animation,
                          //将要执行动画的子view
                          child: Container(
                            key: Key("start"),
                            height: 60.0,
                            width: 60.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
                              image: DecorationImage(
                                  fit: BoxFit.fill, //这个地方很重要，需要设置才能充满
                                  image: FileManager.musicAlbumPictureImage(
                                      _musicInfoModel.artist,
                                      _musicInfoModel.album)),
                            ),
                          ),
                        )
                      : Container(
                          key: Key("stop"),
                          height: 60.0,
                          width: 60.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            image: DecorationImage(
                              fit: BoxFit.fill, //这个地方很重要，需要设置才能充满
                              image: FileManager.musicAlbumPictureImage(
                                  _musicInfoModel.artist,
                                  _musicInfoModel.album),
                            ),
                          ),
                        ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            !musicInfoFavIDSet.contains(_musicInfoModel.id)
                                ? Text("")
                                : Flex(
                                    direction: Axis.horizontal,
                                    children: <Widget>[
                                      Icon(
                                        CupertinoIcons.heart_solid,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                            const Padding(padding: EdgeInsets.only(right: 5.0)),
                            Expanded(
                              child: Text(
                                _musicInfoModel.type != "fold"
                                    ? '${_musicInfoModel.title} - ${_musicInfoModel.artist}'
                                    : "",
                                maxLines: 1,
                                style: themeData.textTheme.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.only(top: 8.0)),
                        Text(
                          _musicInfoModel.type != "fold"
                              ? '${_musicInfoModel.album}'
                              : "",
                          style: themeData.primaryTextTheme.subtitle,
                        ),
                      ],
                    ),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(
                    Icons.more_horiz,
                    semanticLabel: 'Add',
                  ),
                  onPressed: () {
                    Navigator.of(context).push(CupertinoPageRoute<void>(
                      title: "hehe",
                      builder: (BuildContext context) => MyHttpServer(
                          // color: color,
                          // colorName: colorName,
                          // index: index,
                          ),
                    ));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return row;
  }
}
