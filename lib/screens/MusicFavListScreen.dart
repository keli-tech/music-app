import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/components/PlayListRowItem.dart';
import 'package:hello_world/models/MusicPlayListModel.dart';
import 'package:hello_world/screens/PlayListDetailScreen.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:hello_world/services/MusicControlService.dart';
import 'package:hello_world/utils/ToastUtils.dart';
import 'package:provider/provider.dart';

import '../models/MusicInfoModel.dart';
import '../services/Database.dart';

class MusicFavListScreen extends StatefulWidget {
  @override
  _MusicFavListScreen createState() => _MusicFavListScreen();
}

const List<Color> coolColors = <Color>[
  Color.fromARGB(255, 255, 149, 0),
  Color.fromARGB(255, 255, 204, 0),
  Color.fromARGB(255, 255, 59, 48),
  Color.fromARGB(255, 76, 217, 100),
  Color.fromARGB(255, 90, 200, 250),
  Color.fromARGB(255, 0, 122, 255),
  Color.fromARGB(255, 88, 86, 214),
  Color.fromARGB(255, 255, 45, 85),
];

Color getColor(int index) {
  return coolColors[index % coolColors.length];
}

class _MusicFavListScreen extends State<MusicFavListScreen>
    with SingleTickerProviderStateMixin {
  List<MusicInfoModel> _musicInfoModels = [];
  Animation<double> animation;
  AnimationController controller;
  List<MusicPlayListModel> _musicSceenListModels = [];
  List<MusicPlayListModel> _musicPlayListModels = [];

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

    DBProvider.db
        .getMusicPlayListByType(MusicPlayListModel.TYPE_SCEEN)
        .then((onValue) {
      setState(() {
        _musicSceenListModels = onValue;
      });
    });

    DBProvider.db.getMusicPlayList().then((onValue) {
      setState(() {
        _musicPlayListModels = onValue;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    var musicInfoData = Provider.of<MusicInfoData>(context, listen: false);
    var windowHeight = MediaQuery.of(context).size.height;
    var windowWidth = MediaQuery.of(context).size.width;

    return Container(
      color: themeData.backgroundColor,
      child: CupertinoPageScaffold(
        backgroundColor: themeData.backgroundColor,
        child: RefreshIndicator(
          color: Colors.white,
          backgroundColor: themeData.primaryColor,
          child: CustomScrollView(
            semanticChildCount: _musicInfoModels.length,
            slivers: <Widget>[
              CupertinoSliverNavigationBar(
                backgroundColor: themeData.backgroundColor,
              ),
              SliverPadding(
                padding: EdgeInsets.only(left: 5, top: 5, right: 5, bottom: 0),
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
                padding: EdgeInsets.only(left: 5, top: 0, right: 5, bottom: 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Container(
                        color: Colors.white,
                        child: Column(
                          children: <Widget>[
                            Card(
                              elevation: 0,
                              color: Colors.white,
                              child: ListTile(
                                title: Text(
                                  "歌单",
                                  style: themeData.primaryTextTheme.title,
                                ),
                                trailing: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    _addSceen();
                                  },
                                  child: Icon(Icons.add_circle_outline),
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
                // Top media padding consumed by CupertinoSliverNavigationBar.
                // Left/Right media padding consumed by Tab1RowItem.
                padding: EdgeInsets.only(left: 8, top: 5, right: 8, bottom: 8),
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
                padding: EdgeInsets.only(left: 5, top: 0, right: 5, bottom: 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Card(
                        elevation: 0,
                        color: Colors.white,
                        child: ListTile(
                          title: Text(
                            "场景",
                            style: themeData.primaryTextTheme.title,
                          ),
                          trailing: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              _addSceen();
                            },
                            child: Icon(Icons.add_circle_outline),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.only(left: 5, top: 5, right: 5, bottom: 70),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _musicSceenListModels.length > 0
                        ? Card(
                            elevation: 0,
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Wrap(
                                spacing: 8.0, // 主轴(水平)方向间距
                                runSpacing: 4.0, // 纵轴（垂直）方向间距
                                alignment: WrapAlignment.center, //沿主轴方向居中
                                children: _musicSceenListModels
                                    .asMap()
                                    .keys
                                    .toList()
                                    .map((index) {
                                  return GestureDetector(
                                    child: Chip(
                                      deleteIcon: Icon(
                                        Icons.play_circle_outline,
                                        color: getColor(index),
                                      ),
                                      padding: EdgeInsets.all(9.0),
                                      avatar: new CircleAvatar(
                                          backgroundColor: Colors.white70,
                                          child: Icon(
                                            Icons.play_circle_outline,
                                            color: getColor(index),
                                          )),
                                      backgroundColor: getColor(index),
                                      label: new Text(
                                        _musicSceenListModels[index].name,
                                        style: TextStyle(
                                          fontSize: 25,
                                        ),
                                      ),
                                    ),
                                    onDoubleTap: () {
                                      print('on double tap');
                                    },
                                    onLongPress: () {
                                      print('on long press');

                                      Navigator.of(context)
                                          .push(CupertinoPageRoute<void>(
                                        title:
                                            _musicSceenListModels[index].name,
                                        builder: (BuildContext context) =>
                                            PlayListDetailScreen(
                                          musicPlayListModel:
                                              _musicSceenListModels[index],
                                          statusBarHeight:
                                              MediaQuery.of(context)
                                                  .padding
                                                  .top,
                                        ),
                                      ));
                                    },
                                    onTap: () async {
                                      List<MusicInfoModel> musicInfoModels =
                                          await DBProvider.db
                                              .getMusicInfoByPlayListId(
                                                  _musicSceenListModels[index]
                                                      .id);
                                      if (musicInfoModels.length > 0) {
                                        MusicControlService.play(
                                            context, musicInfoModels, 0);
                                      }
                                    },
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
              title: "sdf",
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
                    image: FileManager.musicAlbumPictureImage("", ""),
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
                                style: themeData.textTheme.title,
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
          onTap: () {
//                        Navigator.of(context).push(CupertinoPageRoute<void>(
//                          title: "sdf",
//                          builder: (BuildContext context) => PlayListDetailScreen(
//                            musicPlayListModel: musicPlayListModel,
//                            statusBarHeight: MediaQuery.of(context).padding.top,
//                          ),
//                        ));
          },
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
                              color: themeData.textTheme.subtitle.color,
                            ),
                            Expanded(
                              child: Text(
                                '最近100首播放',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: themeData.textTheme.title,
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
                        ToastUtils.show("新建场景完成");
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
        color: themeData.primaryColor,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Hero(
            tag: 'MusicFavListScreen' + musicPlayListModel.id.toString(),
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

class Tab2RowItem extends StatelessWidget {
  const Tab2RowItem({this.index, this.musicPlayListModel});

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
    );

    return row;
  }
}
