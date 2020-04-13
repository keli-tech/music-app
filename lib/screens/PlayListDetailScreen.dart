import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:provider/provider.dart';

import '../models/MusicInfoModel.dart';
import '../services/Database.dart';
import '../services/EventBus.dart';
import 'MyHttpServer.dart';

const int _kChildCount = 50;

class PlayListDetailScreen extends StatefulWidget {
  @override
  _PlayListDetailScreen createState() => _PlayListDetailScreen();
}

class _PlayListDetailScreen extends State<PlayListDetailScreen> {
  _PlayListDetailScreen()
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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    ThemeData themeData = Theme.of(context);
    return CupertinoPageScaffold(
      backgroundColor: themeData.backgroundColor,
      child: CustomScrollView(
        semanticChildCount: _musicInfoModels.length,
        slivers: <Widget>[
//          CupertinoSliverNavigationBar(
//              ),
          SliverAppBar(
            leading: null,
            automaticallyImplyLeading: false,
            forceElevated: true,
            elevation: 10,
            stretch: false,
            pinned: true,
            expandedHeight: width - 50,
            flexibleSpace: Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      image: NetworkImage(
                          'http://p2.music.126.net/VA3kAvrg2YRrxCgDMJzHnw==/3265549618941178.jpg'),
                    ),
                  ),
                ),
//                Positioned(
//                  left: 0,
//                  bottom: 10.0,
//                  child: Card(
//                    child: Container(
//                      height: 40,
//                      width: width,
//                      alignment: Alignment.bottomCenter,
//                      child: new Row(
//                        children: <Widget>[
//                          Text(
//                            "",
//                            style: themeData.textTheme.title,
//                          ),
//                        ],
//                      ),
//                    ),
//                  ),
//                ),
              ],
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
        Provider.of<MusicInfoData>(context, listen: false)
            .setMusicInfoModel(musicInfoModel);

        eventBus.fire(MusicPlayEvent(MusicPlayAction.play));

//        Navigator.of(context).push(CupertinoPageRoute<void>(
//          title: colorName,
//          builder: (BuildContext context) => PlayListDetailScreen(
//            color: color,
//            colorName: colorName,
//            index: index,
//          ),
//        ));
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
                    child: Text(
                  (index + 1).toString() + ".",
                  style: themeData.primaryTextTheme.title,
                )),
                const Padding(padding: EdgeInsets.only(right: 5.0)),
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
                                musicInfoModel.type != "fold"
                                    ? '${musicInfoModel.title}-${musicInfoModel.artist}'
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
                              ? musicInfoModel.album
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
