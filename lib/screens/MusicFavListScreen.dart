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

  _refreshList() async {
    DBProvider.db.getMusicInfoByPath("/").then((onValue) {
      setState(() {
        _musicInfoModels = onValue;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    var dataInfo = Provider.of<MusicInfoData>(context, listen: false);
    print(dataInfo.musicInfoModel.toJson().toString());

    return CupertinoPageScaffold(
      backgroundColor: themeData.backgroundColor,
      child: RefreshIndicator(
        color: Colors.white,
        backgroundColor: themeData.primaryColor,
        child: CustomScrollView(
          semanticChildCount: _musicInfoModels.length,
          slivers: <Widget>[
            CupertinoSliverNavigationBar(
              largeTitle: Text(
                "红心",
                style: themeData.primaryTextTheme.headline,
              ),
              backgroundColor: themeData.backgroundColor,
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                //返回组件集合
                List.generate(1, (int index) {
                  //返回 组件
                  return GestureDetector(
                    onTap: () {
                      print("点击$index");
                    },
                    child: Card(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.all(10),
                        child: CupertinoTextField(
                          controller: _chatTextController,
                          textCapitalization: TextCapitalization.sentences,
                          placeholder: 'search heart',
                          placeholderStyle: themeData.textTheme.title,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 0.0,
                              color: CupertinoColors.inactiveGray,
                            ),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          maxLines: null,
                          keyboardType: TextInputType.text,
                          prefix: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                            child: Icon(CupertinoIcons.search),
                          ),
                          suffix: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: CupertinoButton(
                              color: CupertinoColors.systemGrey3,
                              minSize: 0.0,
                              child: const Icon(
                                CupertinoIcons.clear,
                                size: 21.0,
                                color: CupertinoColors.white,
                              ),
                              padding: const EdgeInsets.all(2.0),
                              borderRadius: BorderRadius.circular(15.0),
                              onPressed: () =>
                                  setState(() => _chatTextController.clear()),
                            ),
                          ),
                          autofocus: false,
                          suffixMode: OverlayVisibilityMode.editing,
                          onSubmitted: (String text) =>
                              setState(() => _chatTextController.clear()),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Consumer<MusicInfoData>(
              builder: (context, musicInfoData, _) => SliverPadding(
                // Top media padding consumed by CupertinoSliverNavigationBar.
                // Left/Right media padding consumed by Tab1RowItem.
                padding: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 70),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return Tab1RowItem(
                        index: index,
                        lastItem: index == _musicInfoModels.length - 1,
                        color: Colors.deepPurple,
                        colorName: "colorName",
                        musicInfoModels: _musicInfoModels,
                        playIndex: musicInfoData.playIndex,
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
    );
  }
}

class Tab1RowItem extends StatelessWidget {
  const Tab1RowItem(
      {this.index,
      this.lastItem,
      this.color,
      this.colorName,
      this.musicInfoModels,
      this.playIndex,
      this.animation,
      this.controller});

  final int index;
  final bool lastItem;
  final Color color;
  final String colorName;
  final List<MusicInfoModel> musicInfoModels;
  final int playIndex;

  final Animation<double> animation;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    MusicInfoModel musicInfoModel = musicInfoModels[index];

    final Widget row = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // todo 2 to 1
        List<MusicInfoModel> mims =
            musicInfoModels.getRange(0, musicInfoModels.length - 1).toList();
        mims.removeWhere((music) {
          return music.type == "fold";
        });
        Provider.of<MusicInfoData>(context, listen: false)
            .setMusicInfoModels(mims);
        Provider.of<MusicInfoData>(context, listen: false).setPlayIndex(index);

        controller.reset();

        controller.forward();
        eventBus.fire(MusicPlayEvent(MusicPlayAction.play));
      },
      child: Container(
        color:
            CupertinoDynamicColor.resolve(themeData.backgroundColor, context),
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
                  child: musicInfoModels.length > 0 &&
                          musicInfoModels[playIndex].id == musicInfoModel.id
                      ? RotateTransform(
                          animation: animation,
                          //将要执行动画的子view
                          child: Container(
                            key: Key("start"),
                            height: 60.0,
                            width: 60.0,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(30.0),
                              image: DecorationImage(
                                  fit: BoxFit.fill, //这个地方很重要，需要设置才能充满
                                  image: FileManager.musicAlbumPictureImage(
                                      musicInfoModel.artist,
                                      musicInfoModel.album)),
                            ),
                          ),
                        )
                      : Container(
                          key: Key("stop"),
                          height: 60.0,
                          width: 60.0,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8.0),
                            image: DecorationImage(
                              fit: BoxFit.fill, //这个地方很重要，需要设置才能充满
                              image: FileManager.musicAlbumPictureImage(
                                  musicInfoModel.artist, musicInfoModel.album),
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
                            Flex(
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
                                musicInfoModel.type != "fold"
                                    ? '${musicInfoModel.title} - ${musicInfoModel.artist}'
                                    : "",
                                maxLines: 1,
                                style: themeData.primaryTextTheme.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.only(top: 8.0)),
                        Text(
                          musicInfoModel.type != "fold"
                              ? '${musicInfoModel.album}'
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
                      title: colorName,
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
