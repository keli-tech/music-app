import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/models/MusicInfoModel.dart';

import '../models/MusicInfoModel.dart';
import '../services/Database.dart';
import 'MyHttpServer.dart';
import 'PlayListDetailScreen.dart';

const int _kChildCount = 50;

class PlayListScreen extends StatefulWidget {
  // const PlayListScreen({this.colorItems, this.colorNameItems});

  @override
  _PlayListScreen createState() => _PlayListScreen();
}

class _PlayListScreen extends State<PlayListScreen> {
  _PlayListScreen()
      : colorItems = List<Color>.generate(_kChildCount, (int index) {
          return Colors.deepPurple;
        }),
        colorNameItems = List<String>.generate(_kChildCount, (int index) {
          return "helloworld";
        });

  final List<Color> colorItems;
  final List<String> colorNameItems;

  List<MusicInfoModel> _musicInfoModels = [];
  TextEditingController _chatTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _refreshList();
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

    return CupertinoPageScaffold(
      backgroundColor: themeData.backgroundColor,
      child: CustomScrollView(
        semanticChildCount: _musicInfoModels.length,
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            largeTitle: Text(
              "歌单",
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
                    Navigator.of(context).push(CupertinoPageRoute<void>(
                      title: "文件同步",
                      builder: (BuildContext context) => MyHttpServer(
                          // color: color,
                          // colorName: colorName,
                          // index: index,
                          ),
                    ));
                  },
                  child: Card(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(
                          left: 30, top: 20, right: 30, bottom: 20),
                      child: Row(children: <Widget>[
                        Icon(
                          Icons.add,
                          size: 30,
                          color: CupertinoColors.activeGreen,
                        ),
                        const Padding(padding: EdgeInsets.only(right: 20.0)),
                        Text(
                          "新建歌单",
                          style: themeData.textTheme.title,
                        ),
                      ]),
                    ),
                  ),
                );
              }),
            ),
          ),
          SliverPadding(
            // Top media padding consumed by CupertinoSliverNavigationBar.
            // Left/Right media padding consumed by Tab1RowItem.
            padding: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 70),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Tab1RowItem(
                    index: index,
                    lastItem: index == _musicInfoModels.length - 1,
                    color: colorItems[index],
                    colorName: colorNameItems[index],
                    musicInfoModel: _musicInfoModels[index],
                  );
                },
                childCount: _musicInfoModels.length,
              ),
            ),
          ),
        ],
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
      this.musicInfoModel});

  final int index;
  final bool lastItem;
  final Color color;
  final String colorName;
  final MusicInfoModel musicInfoModel;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    final Widget row = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute<void>(
          title: colorName,
          builder: (BuildContext context) => PlayListDetailScreen(),
        ));
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
                Container(
                  height: 76.0,
                  width: 114.0,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      fit: BoxFit.fill, //这个地方很重要，需要设置才能充满
                      image: NetworkImage(
                          'http://p2.music.126.net/VA3kAvrg2YRrxCgDMJzHnw==/3265549618941178.jpg'),
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
                            Expanded(
                              child: Text(
                                musicInfoModel.name,
                                maxLines: 1,
                                style: themeData.primaryTextTheme.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.only(top: 8.0)),
                        Text(
                          "18首",
                          style: themeData.primaryTextTheme.subtitle,
                        ),
                      ],
                    ),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(
                    Icons.play_circle_outline,
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

//    if (lastItem) {
//      return row;
//    }

    return row;

//    return Column(
//      children: <Widget>[
//        row,
//        Container(
//          height: 1.0,
//          color:
//              CupertinoDynamicColor.resolve(CupertinoColors.separator, context),
//        ),
//      ],
//    );
  }
}
