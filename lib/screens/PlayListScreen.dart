import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/models/MusicPlayListModel.dart';
import 'package:hello_world/services/FileManager.dart';

import '../components/PlayListCreateComp.dart';
import '../services/Database.dart';
import 'PlayListDetailScreen.dart';

class PlayListScreen extends StatefulWidget {
  @override
  _PlayListScreen createState() => _PlayListScreen();
}

class _PlayListScreen extends State<PlayListScreen> {
  List<MusicPlayListModel> _musicPlayListModels = [];
  TextEditingController _chatTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("play list did updte widget");

    _refreshList();
  }

  @override
  void deactivate() {
    super.deactivate();
    print("play list did deactivate");

    _refreshList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("play list did didChangeDependencies");

    _refreshList();
  }

  _refreshList() async {
    DBProvider.db.getMusicPlayList().then((onValue) {
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
          SliverPadding(
            // Top media padding consumed by CupertinoSliverNavigationBar.
            // Left/Right media padding consumed by Tab1RowItem.
            padding: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 70),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Tab1RowItem(
                    index: index,
                    lastItem: index == _musicPlayListModels.length - 1,
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
          onPressed: () {
            Navigator.of(context1).pop();

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
        ),
        CupertinoActionSheetAction(
          child: Text(
            '歌单排序',
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
  const Tab1RowItem({this.index, this.lastItem, this.musicPlayListModel});

  final int index;
  final bool lastItem;
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
                Hero(
                  tag: musicPlayListModel.id,
                  child: Container(
                    height: 76.0,
                    width: 114.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        fit: BoxFit.cover, //这个地方很重要，需要设置才能充满
                        image: FileManager.musicAlbumPictureImage(
                            musicPlayListModel.artist, musicPlayListModel.name),
                      ),
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
                                musicPlayListModel.name,
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
                    size: 35,
                    semanticLabel: 'Add',
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return row;
  }
}
