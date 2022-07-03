// import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/common/Global.dart';
import 'package:hello_world/components/Tile.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/models/MusicPlayListModel.dart';

// import 'package:hello_world/services/AdmobService.dart3';
import 'package:hello_world/services/FileManager.dart';
import 'package:hello_world/services/MusicControlService.dart';
import 'package:provider/provider.dart';

import '../../services/Database.dart';
import '../album/PlayListDetailScreen.dart';

class AlbumListScreen extends StatefulWidget {
  AlbumListScreen({
    Key? key,
  }) : super(key: key);
  static const String className = 'AlbumListScreen';

  @override
  _AlbumListScreen createState() => _AlbumListScreen();
}

class _AlbumListScreen extends State<AlbumListScreen> {
  List<MusicPlayListModel> _musicPlayListModels = [];
  List<Map<String, String>> _artistListModels = [];
  bool _isLoding = false;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  @override
  void deactivate() {
    super.deactivate();
    _refreshList();
  }

  _refreshList() async {
    DBProvider.db.getAlbum().then((onValue) {
      setState(() {
        _musicPlayListModels = onValue;
      });
    });

    DBProvider.db.getArtists().then((onValue) {
      setState(() {
        _artistListModels = onValue;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    var _windowHeight = MediaQuery.of(context).size.height;
    var _windowWidth = MediaQuery.of(context).size.width;
    var _bottomBarHeight = MediaQuery.of(context).padding.bottom;

    return CupertinoPageScaffold(
        backgroundColor: themeData.backgroundColor,
        navigationBar: CupertinoNavigationBar(
          border: null,
          middle: Text(
            "专辑",
            style: themeData.primaryTextTheme.headline6,
          ),
          backgroundColor: themeData.backgroundColor,
        ),
        child: RefreshIndicator(
          color: Colors.white,
          backgroundColor: themeData.primaryColor,
          child: CupertinoScrollbar(
            child: CustomScrollView(
                semanticChildCount: _musicPlayListModels.length,
                slivers: <Widget>[
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 8.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Global.showAd
                              ? Container(
                                  // child: AdmobBanner(
                                  //   adUnitId: AdMobService.getBannerAdUnitId(
                                  //       AlbumListScreen.className),
                                  //   adSize: AdmobBannerSize.FULL_BANNER,
                                  //   listener: (AdmobAdEvent event,
                                  //       Map<String, dynamic> args) {
                                  //     AdMobService.handleEvent(
                                  //         event, args, 'Banner');
                                  //   },
                                  // ),
                                  )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                  Consumer<MusicInfoData>(
                    builder: (context, musicInfoData, _) => SliverPadding(
                      padding: EdgeInsets.only(
                          left: 15,
                          top: 10,
                          right: 15,
                          bottom: _bottomBarHeight + 50),
                      sliver: SliverGrid(
                        //Grid
                        gridDelegate:
                            new SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10.0,
                          crossAxisSpacing: 15.0,
                          childAspectRatio: 1,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return Tab1RowItem(
                              index: index,
                              musicPlayListModel: _musicPlayListModels[index],
                            );
                          },
                          childCount: _musicPlayListModels.length,
                        ),
                      ),
                    ),
                  ),
                ]),
          ),
          onRefresh: () async {
            if (!_isLoding) {
              setState(() {
                _isLoding = true;
              });
              return _refreshList().then((value) {
                setState(() {
                  _isLoding = false;
                });
              }).catchError((error) {
                print(error);
              });
            }
          },
        ));
  }

  // 底部弹出菜单actionSheet
  Widget _actionSheet(BuildContext context1, BuildContext context) {
    ThemeData themeData = Theme.of(context);
    var windowHeight = MediaQuery.of(context).size.height;

    return new CupertinoActionSheet(
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text(
            '新建歌单',
          ),
          onPressed: () {
            Navigator.of(context1).pop();
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            '歌单排序',
          ),
          onPressed: () {
            Navigator.pop(context1);
          },
        ),
      ],
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

class Tab1RowItem extends StatelessWidget {
  const Tab1RowItem({required this.index, required this.musicPlayListModel});

  final int index;
  final MusicPlayListModel musicPlayListModel;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    final Widget row = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute<void>(
          title: musicPlayListModel.getName(),
          builder: (BuildContext context) => PlayListDetailScreen(
            musicPlayListModel: musicPlayListModel,
            statusBarHeight: MediaQuery.of(context).padding.top,
          ),
        ));
      },
      child: Container(
        color: themeData.backgroundColor,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Hero(
            tag: 'AlbumListScreen' + musicPlayListModel.getId().toString(),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  fit: BoxFit.cover, //这个地方很重要，需要设置才能充满
                  image: FileManager.musicAlbumPictureImage(
                      musicPlayListModel.getArtist(),
                      musicPlayListModel.getName()),
                ),
              ),
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8.0),
                            bottomRight: Radius.circular(8.0),
                          ),
                          color: themeData.highlightColor,
                        ),
                        child: Row(children: <Widget>[
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '${musicPlayListModel.getName()}',
                                  maxLines: 1,
                                  style: themeData.textTheme.headline6,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${musicPlayListModel.getArtist()}',
                                  maxLines: 1,
                                  style: themeData.textTheme.subtitle2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Tile(
                              selected: false,
                              blur: 5,
                              radiusnum: 20,
                              child: Icon(
                                Icons.play_circle_outline,
                                color:
                                    themeData.primaryTextTheme.headline6?.color,
                                size: 25,
                              ),
                            ),
                            onPressed: () async {
                              var _musicInfoModels = await DBProvider.db
                                  .getMusicInfoByPlayListId(
                                      musicPlayListModel.getId());

                              MusicControlService.play(
                                  context, _musicInfoModels, 0);
                            },
                          ),
                        ])),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return row;
  }
}
