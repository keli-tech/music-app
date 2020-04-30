import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/common/Global.dart';
import 'package:hello_world/components/Tile.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/models/MusicPlayListModel.dart';
import 'package:hello_world/services/AdmobService.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:hello_world/services/MusicControlService.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import '../../services/Database.dart';
import '../album/PlayListDetailScreen.dart';

class AlbumListScreen extends StatefulWidget {
  AlbumListScreen({
    Key key,
  }) : super(key: key);
  static const String className = 'MyHttpServer';

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
            style: themeData.primaryTextTheme.title,
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
                                  child: AdmobBanner(
                                    adUnitId: AdMobService.getBannerAdUnitId(
                                        AlbumListScreen.className),
                                    adSize: AdmobBannerSize.FULL_BANNER,
                                    listener: (AdmobAdEvent event,
                                        Map<String, dynamic> args) {
                                      AdMobService.handleEvent(
                                          event, args, 'Banner');
                                    },
                                  ),
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
                          bottom: _bottomBarHeight + 70),
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
          onRefresh: () {
            if (_isLoding) return null;
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
          },
        ));
  }
}

class Tab1RowItem extends StatelessWidget {
  const Tab1RowItem({this.index, this.musicPlayListModel});

  final int index;
  final MusicPlayListModel musicPlayListModel;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    final Widget row = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context, rootNavigator: true)
            .push(MaterialWithModalsPageRoute<void>(
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
            tag: 'AlbumListScreen' + musicPlayListModel.id.toString(),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  fit: BoxFit.cover, //这个地方很重要，需要设置才能充满
                  image: FileManager.musicAlbumPictureImage(
                      musicPlayListModel.artist, musicPlayListModel.name),
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
                                  '${musicPlayListModel.name}',
                                  maxLines: 1,
                                  style: themeData.textTheme.title,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${musicPlayListModel.artist}',
                                  maxLines: 1,
                                  style: themeData.textTheme.subtitle,
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
                                color: themeData.primaryTextTheme.title.color,
                                size: 25,
                              ),
                            ),
                            onPressed: () async {
                              var _musicInfoModels = await DBProvider.db
                                  .getMusicInfoByPlayListId(
                                      musicPlayListModel.id);

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
