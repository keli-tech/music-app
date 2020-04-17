import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hello_world/components/FileSelectorContainer.dart';
import 'package:hello_world/components/PlayListCreateComp.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/models/MusicPlayListModel.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:provider/provider.dart';

import '../models/MusicInfoModel.dart';
import '../services/Database.dart';
import '../services/EventBus.dart';
import 'MyHttpServer.dart';

const int _kChildCount = 50;

class PlayListDetailScreen extends StatefulWidget {
  PlayListDetailScreen({Key key, this.musicPlayListModel, this.statusBarHeight})
      : super(key: key);
  static const String routeName = '/playlist/detail';

  @override
  _PlayListDetailScreen createState() => _PlayListDetailScreen();

  double statusBarHeight;

  MusicPlayListModel musicPlayListModel;
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

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);

    _refreshList();
  }

  _refreshList() async {
    int plid = widget.musicPlayListModel.id;
//    print("refreshing" + plid.toString());
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
      child: CustomScrollView(
        semanticChildCount: _musicInfoModels.length,
        slivers: <Widget>[
//          CupertinoSliverNavigationBar(
//              ),
          SliverAppBar(
            automaticallyImplyLeading: false,
            forceElevated: true,
            elevation: 10,
            stretch: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            expandedHeight: width - 80,
//            leading: CupertinoButton(
//              padding: EdgeInsets.zero,
//              child: const Icon(
//                Icons.keyboard_arrow_left,
//                size: 35,
//                semanticLabel: 'Add',
//              ),
//              onPressed: () {
//                Navigator.of(context).pop();
//              },
//            ),
            flexibleSpace: Stack(
              children: <Widget>[
                Hero(
                  tag: widget.musicPlayListModel.id,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0)),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileManager.musicAlbumPictureImage(
                            widget.musicPlayListModel.artist,
                            widget.musicPlayListModel.name),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  bottom: 0.0,
                  child: Center(
                    child: Container(
                      height: 80,
                      width: width,
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(8.0),
                            bottomLeft: Radius.circular(8.0)),
                      ),
                      child: new Column(
                        children: <Widget>[
                          SizedBox(height: MediaQuery.of(context).padding.top),
                          Container(
                            height: 80 - MediaQuery.of(context).padding.top,
                            child: ListTile(
                              title: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                          widget.musicPlayListModel.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: themeData
                                              .primaryTextTheme.headline),
                                    ),
                                  ),
                                ],
                              ),
                              leading: CupertinoButton(
                                padding: EdgeInsets.zero,
                                child: const Icon(
                                  Icons.keyboard_arrow_left,
                                  size: 35,
                                  semanticLabel: 'Add',
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              trailing: IconButton(
                                icon: Icon(
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

//                            child: new Row(
//                              mainAxisAlignment: MainAxisAlignment.center,
//                              crossAxisAlignment: CrossAxisAlignment.center,
//                              children: <Widget>[
//                                Text(
//                                  widget.musicPlayListModel.name,
//                                  style: themeData.textTheme.title,
//                                ),
//                                Text(
//                                  widget.musicPlayListModel.name,
//                                  style: themeData.textTheme.title,
//                                ),
//                              ],
//                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
                    colorName: colorNameItems[index],
                    musicInfoModel: _musicInfoModels[index],
                    musicInfoModels: _musicInfoModels,
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

class Tab1RowItem extends StatelessWidget {
  const Tab1RowItem({
    this.index,
    this.lastItem,
    this.colorName,
    this.musicInfoModel,
    this.musicInfoModels,
  });

  final int index;
  final bool lastItem;
  final String colorName;
  final MusicInfoModel musicInfoModel;
  final List<MusicInfoModel> musicInfoModels;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    final Widget row = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Provider.of<MusicInfoData>(context, listen: false)
            .setMusicInfoList(musicInfoModels);
        Provider.of<MusicInfoData>(context, listen: false).setPlayIndex(index);

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
                                style: themeData.textTheme.title,
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
  }
}
