import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/components/ChipScreenComp.dart';
import 'package:hello_world/components/PlayListRowItem.dart';
import 'package:hello_world/models/MusicPlayListModel.dart';
import 'package:hello_world/screens/PlayListDetailScreen.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:hello_world/services/MusicControlService.dart';
import 'package:hello_world/utils/ToastUtils.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../models/MusicInfoModel.dart';
import '../services/Database.dart';

class MusicFavListScreen extends StatefulWidget {
  @override
  _MusicFavListScreen createState() => _MusicFavListScreen();
}

class _MusicFavListScreen extends State<MusicFavListScreen>
    with SingleTickerProviderStateMixin {
  List<MusicInfoModel> _musicInfoModels = [];
  Animation<double> animation;
  AnimationController controller;
  List<MusicPlayListModel> _musicSceenListModels = [];
  List<MusicPlayListModel> _musicPlayListModels = [];

  MusicPlayListModel _favPlayListInfo;

  Logger _logger = new Logger("MusicFavListScreen");

  bool _isLoding = false;
  TextEditingController _chatTextController;

  @override
  void initState() {
    super.initState();

    _chatTextController = TextEditingController();

    _refreshList();
  }

  //销毁
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    print("mfl sreassemble");
  }

  @override
  void deactivate() {
    super.deactivate();
    _logger.info("deactivate");

    _refreshList();
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);

    _refreshList();
  }

  _refreshList() async {
    DBProvider.db.getFavMusicInfoList().then((onValue) {
      // 红心 ID Set
      Set<int> musicInfoFavIDSet = onValue.map((f) {
        return f.id;
      }).toSet();

      Provider.of<MusicInfoData>(context, listen: false)
          .setMusicInfoFavIDSet(musicInfoFavIDSet);

      setState(() {
        _musicInfoModels = onValue;
      });
    });

    var musicSceenListModels = await DBProvider.db
        .getMusicPlayListByType(MusicPlayListModel.TYPE_SCEEN);
    var musicPlayListModels = await DBProvider.db.getMusicPlayList();
    var musicPlayListModel = await DBProvider.db
        .getMusicPlayListById(MusicPlayListModel.FAVOURITE_PLAY_LIST_ID);

    setState(() {
      _musicSceenListModels = musicSceenListModels;
      _musicPlayListModels = musicPlayListModels;
      _favPlayListInfo = musicPlayListModel;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    var musicInfoData = Provider.of<MusicInfoData>(context, listen: false);
    var windowHeight = MediaQuery.of(context).size.height;
    var windowWidth = MediaQuery.of(context).size.width;

    return CupertinoPageScaffold(
      backgroundColor: themeData.backgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: themeData.backgroundColor,
        trailing: CupertinoButton(
          child: Icon(
            Icons.more_vert,
            color: themeData.primaryColor,
          ),
          onPressed: () {
            showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context1) {
                return _actionSheet(context1, context);
              },
            );
          },
        ),
      ),
      child: RefreshIndicator(
        color: Colors.white,
        backgroundColor: themeData.primaryColor,
        child: CustomScrollView(
          semanticChildCount: _musicInfoModels.length,
          slivers: <Widget>[
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Flex(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: _buildFavList(context),
                      ),
                      Expanded(
                        flex: 1,
                        child: _buildHistory100(context),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      color: themeData.backgroundColor,
                      child: Column(
                        children: <Widget>[
                          new Divider(),
                          Card(
                            elevation: 0,
                            color: themeData.backgroundColor,
                            child: ListTile(
                              title: Text(
                                "歌单",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return PlayListRowItem(
                      index: index,
                      musicPlayListModel: _musicPlayListModels[index],
                    );
                  },
                  childCount: _musicPlayListModels.length,
                ),
              ),
            ),
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    new Divider(),
                    _musicSceenListModels.length > 0
                        ? Card(
                            elevation: 0,
                            child: ListTile(
                              title: Text(
                                "场景",
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _musicSceenListModels.length > 0
                      ? Card(
                          elevation: 0,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 70.0),
                            child: Wrap(
                              spacing: 8.0, // 主轴(水平)方向间距
                              runSpacing: 4.0, // 纵轴（垂直）方向间距
                              alignment: WrapAlignment.center, //沿主轴方向居中
                              children: _musicSceenListModels
                                  .asMap()
                                  .keys
                                  .toList()
                                  .map((index) {
                                return ChipScreenComp(
                                  refreshFunc: _refreshList,
                                  index: index,
                                  musicPlayListModel:
                                      _musicSceenListModels[index],
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      : Container(),
                ]),
              ),
            ),
          ],
        ),
        onRefresh: () {
          if (_isLoding) return null;
          setState(() {
            _isLoding = true;
          });
          return _refreshList().then((value) {
            print('success');
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
  Widget _actionSheet(BuildContext context1, BuildContext context) {
    ThemeData themeData = Theme.of(context);
    var windowHeight = MediaQuery.of(context).size.height;

    return new CupertinoActionSheet(
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text(
            '新建歌单',
          ),
          onPressed: () {
            Navigator.of(context1).pop();

            _addPlayList();
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            '新建场景',
          ),
          onPressed: () {
            Navigator.pop(context1);

            _addSceen();
          },
        ),
      ],
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

  Widget _buildFavList(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    var musicInfoData = Provider.of<MusicInfoData>(context, listen: false);
    var windowHeight = MediaQuery.of(context).size.height;
    var windowWidth = MediaQuery.of(context).size.width;

    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: Container(
        color: Colors.transparent,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
//            var musicPlayListModel = await DBProvider.db.getFavMusicInfoList();
            var musicPlayListModel = await DBProvider.db.getMusicPlayListById(
                MusicPlayListModel.FAVOURITE_PLAY_LIST_ID);

            Navigator.of(context).push(CupertinoPageRoute<void>(
              title: "我喜欢的音乐",
              builder: (BuildContext context) => PlayListDetailScreen(
                musicPlayListModel: musicPlayListModel,
                statusBarHeight: MediaQuery.of(context).padding.top,
              ),
            ));
          },
          child: Container(
            color: Colors.transparent,
            child: SafeArea(
              top: false,
              bottom: false,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileManager.musicAlbumPictureImage(
                        "-", _favPlayListInfo.imgpath),
                  ),
                ),
                child: Container(
                  color: Colors.transparent,
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
                            Icon(
                              CupertinoIcons.heart_solid,
                              color: Colors.red,
                            ),
                            Expanded(
                              child: Text(
                                '我喜欢的音乐',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: const Icon(
                                Icons.play_circle_outline,
                                size: 35,
                              ),
                              onPressed: () async {
                                var _musicInfoModels =
                                    await DBProvider.db.getFavMusicInfoList();

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
      ),
    );
  }

  Widget _buildHistory100(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    var musicInfoData = Provider.of<MusicInfoData>(context, listen: false);
    var windowHeight = MediaQuery.of(context).size.height;
    var windowWidth = MediaQuery.of(context).size.width;

    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: Container(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {},
          child: Container(
            width: windowWidth / 2,
            color: themeData.backgroundColor,
            child: SafeArea(
              top: false,
              bottom: false,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    fit: BoxFit.cover, //这个地方很重要，需要设置才能充满
                    image: AssetImage("assets/images/logo.png"),
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
                            Icon(
                              Icons.history,
                            ),
                            Expanded(
                              child: Text(
                                '最近100首播放',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: const Icon(
                                Icons.play_circle_outline,
                                size: 35,
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
      ),
    );
  }

  _addPlayList() {
    ThemeData themeData = Theme.of(context);
    showCupertinoDialog<String>(
        context: context,
        builder: (BuildContext context1) => CupertinoAlertDialog(
              title: const Text('请输入歌单名'),
              content: CupertinoTextField(
                controller: _chatTextController,
                suffixMode: OverlayVisibilityMode.editing,
                textCapitalization: TextCapitalization.sentences,
                clearButtonMode: OverlayVisibilityMode.editing,
                keyboardType: TextInputType.text,
                autocorrect: false,
                autofocus: true,
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(
                    '取消',
                  ),
                  isDefaultAction: true,
                  onPressed: () => Navigator.pop(context1, 'Cancel'),
                ),
                CupertinoDialogAction(
                    child: Text(
                      '确定',
                    ),
                    isDefaultAction: true,
                    onPressed: () async {
                      if (_chatTextController.text.trim().length == 0) {
                        return;
                      }

                      // 添加到专辑表
                      MusicPlayListModel newMusicPlayListModel =
                          MusicPlayListModel(
                        name: _chatTextController.text.trim(),
                        type: MusicPlayListModel.TYPE_PLAY_LIST,
                        artist: "-",
                        sort: 100,
                      );
                      _chatTextController.clear();

                      int newPlid = await DBProvider.db
                          .newMusicPlayList(newMusicPlayListModel);
                      if (newPlid > 0) {
                        ToastUtils.show("已完成");
                        Navigator.pop(context1, 'Cancel');
                        _refreshList();
                      } else {
                        Navigator.pop(context1, 'Cancel');
                      }
                    }),
              ],
            ));
  }

  _addSceen() {
    ThemeData themeData = Theme.of(context);
    showCupertinoDialog<String>(
        context: context,
        builder: (BuildContext context1) => CupertinoAlertDialog(
              title: const Text('请输入场景'),
              content: CupertinoTextField(
                controller: _chatTextController,
                suffixMode: OverlayVisibilityMode.editing,
                textCapitalization: TextCapitalization.sentences,
                clearButtonMode: OverlayVisibilityMode.editing,
                keyboardType: TextInputType.text,
                autocorrect: false,
                autofocus: true,
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(
                    '取消',
                  ),
                  isDefaultAction: true,
                  onPressed: () => Navigator.pop(context1, 'Cancel'),
                ),
                CupertinoDialogAction(
                    child: Text(
                      '确定',
                    ),
                    isDefaultAction: true,
                    onPressed: () async {
                      if (_chatTextController.text.trim().length == 0) {
                        return;
                      }

                      // 添加到专辑表
                      MusicPlayListModel newMusicPlayListModel =
                          MusicPlayListModel(
                        name: _chatTextController.text.trim(),
                        type: MusicPlayListModel.TYPE_SCEEN,
                        artist: "-",
                        sort: 100,
                      );
                      _chatTextController.clear();

                      int newPlid = await DBProvider.db
                          .newMusicPlayList(newMusicPlayListModel);
                      if (newPlid > 0) {
                        ToastUtils.show("已完成");
                        Navigator.pop(context1, 'Cancel');
                        _refreshList();
                      } else {
                        Navigator.pop(context1, 'Cancel');
                      }
                    }),
              ],
            ));
  }
}
