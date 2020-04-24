import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/models/MusicPlayListModel.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:hello_world/services/MusicControlService.dart';

import '../services/Database.dart';
import 'PlayListDetailScreen.dart';

class AlbumListScreen extends StatefulWidget {
  AlbumListScreen({
    Key key,
  }) : super(key: key);

  @override
  _AlbumListScreen createState() => _AlbumListScreen();
}

class _AlbumListScreen extends State<AlbumListScreen> {
  List<MusicPlayListModel> _musicPlayListModels = [];
  List<Map<String, String>> _artistListModels = [];
  int currentControl = 0;
  bool _isLoding = false;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  @override
  void deactivate() {
    super.deactivate();
    print("album list did deactivate");

    _refreshList();
  }

  _refreshList() async {
    DBProvider.db.getAlbum().then((onValue) {
      setState(() {
        _musicPlayListModels = onValue;
      });
    });

    DBProvider.db.getArtists().then((onValue) {
      print(onValue);
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
        backgroundColor: themeData.backgroundColor,
      ),
      child: RefreshIndicator(
        color: Colors.white,
        backgroundColor: themeData.primaryColor,
        child: Container(
          height: _windowHeight,
          width: _windowWidth,
          child: Column(
            children: <Widget>[
              Container(
                width: _windowWidth,
                child: CupertinoSlidingSegmentedControl(
                  padding: EdgeInsets.all(4.0),
                  groupValue: currentControl,
                  onValueChanged: (int newValue) {
                    setState(() {
                      currentControl = newValue;
                    });
                  },
                  children: {
                    0: Container(
                      alignment: Alignment.center,
                      height: 35,
                      child: Text("专辑"),
                    ),
                    1: Container(
                      alignment: Alignment.center,
                      height: 35,
                      child: Text("歌手"),
                    ),
                  },
                ),
              ),
              Container(
                padding:
                    EdgeInsets.only(left: 5.0, right: 5.0, top: 0, bottom: 0.0),
                height: _windowHeight - _bottomBarHeight - 50 - 160,
                width: _windowWidth,
                child: CupertinoScrollbar(
                    child: CustomScrollView(
                        semanticChildCount: _musicPlayListModels.length,
                        slivers: <Widget>[
                      currentControl == 0
                          ? SliverGrid(
                              //Grid
                              gridDelegate:
                                  new SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, //Grid按两列显示
                                mainAxisSpacing: 10.0,
                                crossAxisSpacing: 10.0,
                                childAspectRatio: 1,
                              ),
                              delegate: new SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  //创建子widget
                                  return Tab1RowItem(
                                    index: index,
                                    musicPlayListModel:
                                        _musicPlayListModels[index],
                                  );
                                },
                                childCount: _musicPlayListModels.length,
                              ),
                            )
                          : SliverList(
                              delegate: new SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  return Card(
                                    color: Colors.transparent,
                                    elevation: 0,
                                    child: ListTile(
                                      onTap: () {
                                        Navigator.of(context)
                                            .push(CupertinoPageRoute<void>(
                                          title: _artistListModels[index]
                                              ["artist"],
                                          builder: (BuildContext context) =>
                                              PlayListDetailScreen(
//                                            musicPlayListModel: musicPlayListModel,
                                            statusBarHeight:
                                                MediaQuery.of(context)
                                                    .padding
                                                    .top,
                                          ),
                                        ));
                                      },
                                      leading: Text(
                                          '${index + 1}. ' +
                                              _artistListModels[index]
                                                  ["artist"],
                                          style: themeData.textTheme.title),
                                    ),
                                  );
                                },
                                childCount: _artistListModels.length,
                              ),
                            )
                    ])),
              ),
            ],
          ),
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
            print('failed');
          });
        },
      ),
    );
  }

  // 底部弹出菜单actionSheet
  Widget actionSheet(BuildContext context1, BuildContext context) {
    ThemeData themeData = Theme.of(context);
    var windowHeight = MediaQuery.of(context).size.height;

    return new CupertinoActionSheet(
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text(
            '新建歌单',
            style: themeData.textTheme.display1,
          ),
          onPressed: () {
            Navigator.of(context1).pop();
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            '歌单排序',
            style: themeData.textTheme.display1,
          ),
          onPressed: () {
            Navigator.pop(context1);
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(
          '取消',
          style: themeData.textTheme.display1,
        ),
        onPressed: () {
          Navigator.of(context1).pop();
        },
      ),
    );
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
        Navigator.of(context).push(CupertinoPageRoute<void>(
          title: musicPlayListModel.name,
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
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8.0),
                            bottomRight: Radius.circular(8.0),
                          ),
                          color: Colors.white70,
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
                                  overflow: TextOverflow.ellipsis,
                                  style: themeData.textTheme.title,
                                ),
                                Text(
                                  '${musicPlayListModel.artist}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: themeData.textTheme.subtitle,
                                ),
                              ],
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: const Icon(
                              Icons.play_circle_outline,
                              size: 35,
                              semanticLabel: 'Add',
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
