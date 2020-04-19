import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hello_world/components/FileSelectorContainer.dart';
import 'package:hello_world/components/MusicRowItem.dart';
import 'package:hello_world/components/PlayListCreateComp.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/models/MusicPlayListModel.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:provider/provider.dart';

import '../models/MusicInfoModel.dart';
import '../services/Database.dart';

// 我喜欢的音乐
// 播放列表
// 专辑
class PlayListDetailScreen extends StatefulWidget {
  PlayListDetailScreen({Key key, this.musicPlayListModel, this.statusBarHeight})
      : super(key: key);
  static const String routeName = '/playlist/detail';

  @override
  _PlayListDetailScreen createState() => _PlayListDetailScreen();

  double statusBarHeight;

  MusicPlayListModel musicPlayListModel;
}

class _PlayListDetailScreen extends State<PlayListDetailScreen>
    with SingleTickerProviderStateMixin {
  List<MusicInfoModel> _musicInfoModels = [];

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);

    _refreshList();
  }

  _refreshList() async {
    int plid = widget.musicPlayListModel.id;
    DBProvider.db.getMusicInfoByPlayListId(plid).then((onValue) {
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
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        actionsForegroundColor: themeData.primaryColor,
        trailing: CupertinoButton(
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
      child: CustomScrollView(
        semanticChildCount: _musicInfoModels.length,
        slivers: <Widget>[
          SliverAppBar(
            brightness: Brightness.light,
            automaticallyImplyLeading: false,
            forceElevated: true,
            elevation: 5,
            stretch: true,
            backgroundColor: Colors.white70,
            expandedHeight: width * 0.7,
            flexibleSpace: Hero(
              tag: widget.musicPlayListModel.id,
              child: new Container(
                decoration: new BoxDecoration(
                  color: Colors.white.withOpacity(0.0),
                  image: new DecorationImage(
                    fit: BoxFit.cover,
                    image: FileManager.musicAlbumPictureImage(
                        widget.musicPlayListModel.artist,
                        widget.musicPlayListModel.name),
                  ),
                ),
              ),
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
                    return MusicRowItem(
                      index: index,
                      musicInfoModels: _musicInfoModels,
                      playId: musicInfoData.musicInfoModel.id,
                      audioPlayerState: musicInfoData.audioPlayerState,
                      musicInfoFavIDSet: musicInfoData.musicInfoFavIDSet,
                    );
                  },
                  childCount: _musicInfoModels.length,
                ),
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
    List<Widget> actionSheets = [];

    actionSheets.add(CupertinoActionSheetAction(
      child: Text(
        '添加歌曲',
        style: themeData.textTheme.display1,
      ),
      onPressed: () {
        Navigator.of(context1).pop();

        showModalBottomSheet<void>(
            context: context,
            useRootNavigator: true,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return FileSelectorContainer(
                title: "添加歌曲",
                playListId: widget.musicPlayListModel.id,
                statusBarHeight: widget.statusBarHeight,
              );
            });
      },
    ));
    actionSheets.add(CupertinoActionSheetAction(
      child: Text(
        '批量操作',
        style: themeData.textTheme.display1,
      ),
      onPressed: () {
        Navigator.of(context1).pop();

        showModalBottomSheet<void>(
            context: context,
            useRootNavigator: true,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return FileSelectorContainer(
                title: "添加歌曲",
                playListId: widget.musicPlayListModel.id,
              );
            });
      },
    ));
    actionSheets.add(CupertinoActionSheetAction(
      child: Text(
        '编辑歌单',
        style: themeData.textTheme.display1,
      ),
      onPressed: () {
        Navigator.pop(context1);

        showModalBottomSheet<void>(
            context: context,
            useRootNavigator: true,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return Container(
                height: windowHeight,
                child: PlayListCreateComp(),
              );
            });
      },
    ));

    if (widget.musicPlayListModel.id !=
        MusicPlayListModel.FAVOURITE_PLAY_LIST_ID) {
      actionSheets.add(CupertinoActionSheetAction(
        child: Text(
          '删除歌单',
          style: themeData.textTheme.display3,
        ),
        onPressed: () {
          Navigator.pop(context1, 'Discard');

          showCupertinoDialog<String>(
            context: context1,
            builder: (BuildContext context1) => CupertinoAlertDialog(
              title: const Text('是否删除歌单?'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(
                    '取消',
                    style: themeData.textTheme.display1,
                  ),
                  isDefaultAction: true,
                  onPressed: () => Navigator.pop(context1, 'Cancel'),
                ),
                CupertinoDialogAction(
                  child: Text(
                    '删除',
                    style: themeData.textTheme.display3,
                  ),
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.pop(context1);

                    DBProvider.db
                        .deleteMusicPlayList(widget.musicPlayListModel.id)
                        .then((onValue) {
                      Fluttertoast.showToast(
                          msg: "已删除歌单",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.TOP,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black45,
                          textColor: Colors.white,
                          fontSize: 13.0);
                      Navigator.pop(context);
                    });
                  },
                ),
              ],
            ),
          ).then((String value) {
            if (value != null) {
//                setState(() { lastSelectedValue = value; });
            }
          });
        },
      ));
    }
    return new CupertinoActionSheet(
      actions: actionSheets,
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
