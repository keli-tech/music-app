import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'PlayListDetailScreen.dart';
import 'MyHttpServer.dart';
import 'dart:convert';

import 'dart:io';
import '../services/Database.dart';
import '../models/MusicInfoModel.dart';
import 'dart:math' as math;
import '../services/EventBus.dart';

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
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: CustomScrollView(
        semanticChildCount: _musicInfoModels.length,
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
              // trailing: trailingButtons,
              ),
          SliverPadding(
            // Top media padding consumed by CupertinoSliverNavigationBar.
            // Left/Right media padding consumed by Tab1RowItem.
            padding: MediaQuery.of(context)
                .removePadding(
                  removeTop: true,
                  removeLeft: true,
                  removeRight: true,
                )
                .padding,
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
    final Widget row = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        eventBus.fire(MusicPlayEvent(MusicPlayAction.play, musicInfoModel));
        return;
        Navigator.of(context).push(CupertinoPageRoute<void>(
          title: colorName,
          builder: (BuildContext context) => PlayListDetailScreen(
            color: color,
            colorName: colorName,
            index: index,
          ),
        ));
      },
      child: Container(
        color: CupertinoDynamicColor.resolve(
            CupertinoColors.systemBackground, context),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(
                left: 16.0, top: 8.0, bottom: 8.0, right: 8.0),
            child: Row(
              children: <Widget>[
                Container(
                  height: 60.0,
                  width: 60.0,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      fit: BoxFit.fill, //这个地方很重要，需要设置才能充满
                      image: NetworkImage(
                          'http://p1.music.126.net/TYwiMwjbr5dfD0K44n-xww==/109951163409466795.jpg'),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          musicInfoModel.name,
                        ),
                        const Padding(padding: EdgeInsets.only(top: 8.0)),
                        Text(
                          musicInfoModel.fullpath,
                          style: TextStyle(
                            color: CupertinoDynamicColor.resolve(
                                CupertinoColors.secondaryLabel, context),
                            fontSize: 13.0,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(
                    CupertinoIcons.plus_circled,
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
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(
                    CupertinoIcons.share,
                    semanticLabel: 'Share',
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (lastItem) {
      return row;
    }

    return Column(
      children: <Widget>[
        row,
        Container(
          height: 1.0,
          color:
              CupertinoDynamicColor.resolve(CupertinoColors.separator, context),
        ),
      ],
    );
  }
}
