import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:hello_world/components/rowitem/MusicRowItem.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

// 我喜欢的音乐
// 播放列表
// 专辑
class MusicFileListComp extends StatefulWidget {
  MusicFileListComp({Key key, this.statusBarHeight}) : super(key: key);
  static const String routeName = '/playlist/detail';

  @override
  _MusicFileListComp createState() => _MusicFileListComp();

  double statusBarHeight;
}

class _MusicFileListComp extends State<MusicFileListComp>
    with SingleTickerProviderStateMixin {
  List<MusicInfoModel> _musicInfoModels = [];
  File _image;
  Logger _logger = new Logger("MusicFileListComp");

  @override
  void initState() {
    super.initState();
  }

//  @override
//  void deactivate() {
//    super.deactivate();
//    _logger.info("deactivate");
//    _refreshList();
//  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    ThemeData themeData = Theme.of(context);
    return Container(
        height: height * 0.6,
        color: themeData.backgroundColor,
        padding: EdgeInsetsDirectional.only(top: widget.statusBarHeight),
        child: CupertinoPageScaffold(
          backgroundColor: themeData.backgroundColor,
          navigationBar: CupertinoNavigationBar(
            border: null,
            backgroundColor: themeData.backgroundColor,
            leading: Container(
                child: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 40,
                color: themeData.primaryColor,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )),
            middle: Text(
              "当前播放列表",
              style: themeData.primaryTextTheme.headline6,
            ),
          ),
          child: CustomScrollView(
            slivers: <Widget>[
              Consumer<MusicInfoData>(
                builder: (context, musicInfoData, _) => SliverPadding(
                  padding:
                      EdgeInsets.only(left: 15, top: 10, right: 15, bottom: 70),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return MusicRowItem(
                          statusBarHeight: widget.statusBarHeight,
                          lastItem: index == musicInfoData.musicInfoList.length - 1,
                          index: index,
                          musicInfoModels:  musicInfoData.musicInfoList,
                          playId: musicInfoData.musicInfoModel.id,
                          audioPlayerState: musicInfoData.audioPlayerState,
                          musicInfoFavIDSet: musicInfoData.musicInfoFavIDSet,
                        );
                      },
                      childCount: musicInfoData.musicInfoList.length,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _actionSheet(BuildContext context1, BuildContext context) {
    ThemeData themeData = Theme.of(context);
    var windowHeight = MediaQuery.of(context).size.height;
    List<Widget> actionSheets = [];

    actionSheets.add(CupertinoActionSheetAction(
      child: Text(
        '添加歌曲',
      ),
      onPressed: () {
        Navigator.of(context1).pop();
      },
    ));

    return new CupertinoActionSheet(
      actions: actionSheets,
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
