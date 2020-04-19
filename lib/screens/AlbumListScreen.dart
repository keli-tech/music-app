import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/models/MusicPlayListModel.dart';
import 'package:hello_world/services/FileManager.dart';

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

//  @override
//  void didChangeDependencies() {
//    super.didChangeDependencies();
//    print("album list did change dependencies");
//
//    _refreshList();
//  }

  _refreshList() async {
    DBProvider.db.getAlbum().then((onValue) {
      setState(() {
        _musicPlayListModels = onValue;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    var windowHeight = MediaQuery.of(context).size.height;

    return CupertinoPageScaffold(
      backgroundColor: themeData.backgroundColor,
      child: CustomScrollView(
        semanticChildCount: _musicPlayListModels.length,
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            backgroundColor: themeData.backgroundColor,
            trailing: Container(
              width: 50,
              height: 50,
              child: FlatButton(
                padding: EdgeInsets.only(left: 0, right: 0),
                child: Icon(
                  Icons.more_vert,
                  color: themeData.primaryColor,
                ),
                onPressed: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (BuildContext context1) {
                      return actionSheet(context1, context);
                    },
                  );
                },
              ),
            ),
          ),
//          SliverList(
//            delegate: SliverChildListDelegate(
//              //返回组件集合
//            ),
//          ),
          SliverPadding(
            padding: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 70),
            sliver: new SliverGrid(
              //Grid
              gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
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
                    musicPlayListModel: _musicPlayListModels[index],
                  );
                },
                childCount: _musicPlayListModels.length,
              ),
            ),
          ),
        ],
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
            tag: musicPlayListModel.id,
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
                        color: Colors.white70,
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
                            onPressed: () {},
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
