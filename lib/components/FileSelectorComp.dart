import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:provider/provider.dart';

import '../common/RotateTransform.dart';
import '../models/MusicInfoModel.dart';
import '../screens/MyHttpServer.dart';
import '../services/Database.dart';
import '../services/EventBus.dart';

class FileSelectorComp extends StatefulWidget {
  FileSelectorComp(
      {Key key,
      this.title,
      this.level,
      this.playListId,
      this.musicInfoModel,
      this.containerContext})
      : super(key: key);

  MusicInfoModel musicInfoModel;
  String title;
  int level;
  int playListId;
  BuildContext containerContext;

  @override
  _FileSelectorComp createState() => _FileSelectorComp();
}

class _FileSelectorComp extends State<FileSelectorComp>
    with SingleTickerProviderStateMixin {
  List<MusicInfoModel> _musicInfoModels = [];
  Animation<double> animation;
  AnimationController controller;
  List<MusicInfoModel> _musicInfoModelsUnderPlayList = [];

  var _eventBusOn;
  bool _isLoding = false;
  List<_ListItem> listItems = [];

  @override
  void initState() {
    super.initState();

    _refreshList();
    controller = new AnimationController(
        duration: const Duration(seconds: 10), vsync: this);
    //图片宽高从0变到300
    animation = new Tween(begin: 0.0, end: 720.0).animate(controller);
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        //动画执行结束时反向执行动画
        controller.reset();

        controller.forward();
      } else if (status == AnimationStatus.dismissed) {
        //动画恢复到初始状态时执行动画（正向）
        controller.forward();
      }
    });

    //启动动画（正向）
    controller.stop();

    _eventBusOn = eventBus.on<MusicPlayEvent>().listen((event) {
      if (event.musicPlayAction == MusicPlayAction.play) {
        controller.forward();
      } else if (event.musicPlayAction == MusicPlayAction.stop) {
        controller.stop();
      }
      setState(() {});
    });
  }

  //销毁
  @override
  void dispose() {
    this._eventBusOn.cancel();
    controller.stop(canceled: true);
    super.dispose();
  }

  _refreshList() async {
    var fullpath = "/";
    if (widget.musicInfoModel != null) {
      fullpath = widget.musicInfoModel.fullpath;
    }
    DBProvider.db.getMusicInfoByPath(fullpath).then((onValue) async {
      _musicInfoModelsUnderPlayList =
          await DBProvider.db.getMusicInfoByPlayListId(widget.playListId);

      var existsIDS = _musicInfoModelsUnderPlayList.map((f) {
        return f.id;
      }).toList();

      var _listItems = onValue.map((f) {
        var checked = existsIDS.indexOf(f.id) >= 0;

        return new _ListItem(f, checked);
      }).toList();

      setState(() {
        listItems = _listItems;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    // 使用底部高度
    var _bottomBarHeight = MediaQuery.of(context).padding.bottom;

//    dynamic obj = ModalRoute.of(context).settings.arguments;
//    if (obj != null && isNotEmpty(obj["name"])) {
//      widget.musicInfoModel = obj["musicInfoModel"];
//    }

    return Container(
      color: themeData.backgroundColor,
//      padding: EdgeInsetsDirectional.only(top: _bottomBarHeight),
      child: Scaffold(
        backgroundColor: themeData.backgroundColor,
        appBar: CupertinoNavigationBar(
          backgroundColor: themeData.backgroundColor,
          leading: FlatButton(
            child: Icon(
              Icons.keyboard_arrow_left,
              size: 40,
              color: themeData.primaryColor,
            ),
            onPressed: () {
              print(1);
              Navigator.of(context).pop();
            },
          ),
          middle: Text(
            widget.title,
            style: themeData.primaryTextTheme.headline,
          ),
          trailing: FlatButton(
              onPressed: () {
                for (int i = 0; i <= widget.level; i++) {
                  print(22222222);
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                "完成",
                style: themeData.primaryTextTheme.title,
              )),
        ),
        body: Scrollbar(
          child: ListView(
//          reverse: _reverse,
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            children: listItems.map<Widget>((item) {
              if (item.musicInfoModel.type == "fold") {
                return buildFoldListTile(item);
              } else {
                return buildListTile(item);
              }
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final _ListItem item = listItems.removeAt(oldIndex);
      listItems.insert(newIndex, item);
    });
  }

  // 文件夹
  Widget buildFoldListTile(_ListItem _listItem) {
    ThemeData themeData = Theme.of(context);

    Widget listTile;

    listTile = ListTile(
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute<void>(
          title: _listItem.musicInfoModel.name,
          builder: (BuildContext context) => FileSelectorComp(
            level: widget.level + 1,
            title: _listItem.musicInfoModel.name,
            musicInfoModel: _listItem.musicInfoModel,
          ),
        ));
      },
      key: Key(_listItem.musicInfoModel.id.toString()),
      isThreeLine: true,
//      value: _listItem.checkState ?? false,
      title: Text(""),
      subtitle: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              '${_listItem.musicInfoModel.name}',
              maxLines: 1,
              style: themeData.textTheme.title,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      leading: Container(
        height: 60.0,
        width: 60.0,
        child: Icon(
          Icons.folder,
          size: 60,
          color: themeData.primaryColor,
        ),
      ),
    );

    return listTile;
  }

  Widget buildListTile(_ListItem _listItem) {
    ThemeData themeData = Theme.of(context);

    const Widget secondary = Text(
      'Even more additional list item information appears on line three.',
    );
    Widget listTile;

    listTile = CheckboxListTile(
      key: Key(_listItem.musicInfoModel.id.toString()),
      isThreeLine: true,
      activeColor: themeData.primaryColor,
      value: _listItem.checkState ?? false,
      onChanged: (bool newChecked) {
        if (newChecked) {
          DBProvider.db
              .addMusicToPlayList(
                  widget.playListId, _listItem.musicInfoModel.id)
              .then((res) {
            if (res > 0) {
              Fluttertoast.showToast(
                  msg: "已添到歌单",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black45,
                  textColor: Colors.white,
                  fontSize: 14.0);
            }
          });
        } else {
          DBProvider.db
              .deleteMusicFromPlayList(
                  widget.playListId, _listItem.musicInfoModel.id)
              .then((res) {
            if (res > 0)
              Fluttertoast.showToast(
                  msg: "已从歌单删除",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black45,
                  textColor: Colors.white,
                  fontSize: 14.0);
          });
        }

        setState(() {
          _listItem.checkState = newChecked;
        });
      },
      title: Row(
        children: <Widget>[
//          Flex(
//            direction: Axis.horizontal,
//            children: <Widget>[
//              Icon(
//                CupertinoIcons.heart_solid,
//                color: Colors.red,
//                size: 16,
//              ),
//            ],
//          ),
//          const Padding(padding: EdgeInsets.only(right: 5.0)),
          Expanded(
            child: Text(
              _listItem.musicInfoModel.type != "fold"
                  ? '${_listItem.musicInfoModel.name}'
                  : "sdsdff",
              maxLines: 1,
              style: themeData.textTheme.title,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      subtitle: Text(
          '${_listItem.musicInfoModel.album} - ${_listItem.musicInfoModel.artist}',
          style: themeData.textTheme.subtitle),
      secondary: Container(
        key: Key("start"),
        height: 60.0,
        width: 60.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          image: DecorationImage(
              fit: BoxFit.fill, //这个地方很重要，需要设置才能充满
              image: FileManager.musicAlbumPictureImage(
                  _listItem.musicInfoModel.artist,
                  _listItem.musicInfoModel.album)),
        ),
      ),
    );

    return listTile;
  }
}

class _ListItem {
  _ListItem(this.musicInfoModel, this.checkState);

  final MusicInfoModel musicInfoModel;

  bool checkState;
}

class Tab1RowItem extends StatelessWidget {
  const Tab1RowItem({
    this.index,
    this.lastItem,
    this.color,
    this.colorName,
    this.musicInfoModels,
    this.playId,
    this.animation,
    this.controller,
  });

  final int index;
  final bool lastItem;
  final Color color;
  final String colorName;
  final List<MusicInfoModel> musicInfoModels;
  final int playId;

  final Animation<double> animation;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    if (musicInfoModels[index].type == "fold") {
      return builderFold(context);
    } else {
      return builder(context);
    }
  }

  Widget builderFold(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    final Widget row = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute<void>(
          title: musicInfoModels[index].name,
          builder: (BuildContext context) => FileSelectorComp(
            musicInfoModel: musicInfoModels[index],
            // colorName: colorName,
            // index: index,
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
                Container(
                  height: 60.0,
                  width: 60.0,
                  child: Icon(
                    Icons.folder,
                    size: 60,
                    color: themeData.primaryColor,
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
                            const Padding(padding: EdgeInsets.only(right: 5.0)),
                            Expanded(
                              child: Text(
                                musicInfoModels[index].name,
                                maxLines: 1,
                                style: themeData.primaryTextTheme.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.only(top: 8.0)),
                        Text(
                          musicInfoModels[index].fullpath,
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

    return row;
  }

  Widget builder(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    MusicInfoModel _musicInfoModel = musicInfoModels[index];
    List<MusicInfoModel> mims =
        musicInfoModels.getRange(0, musicInfoModels.length).toList();
    mims.removeWhere((music) {
      return music.type == "fold";
    });
    int offset = musicInfoModels.length - mims.length;

    final Widget row = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // todo 2 to 1
        Provider.of<MusicInfoData>(context, listen: false)
            .setMusicInfoList(mims);
        Provider.of<MusicInfoData>(context, listen: false)
            .setPlayIndex(index - offset);
        controller.reset();

        controller.forward();
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
                AnimatedSwitcher(
                  transitionBuilder: (child, anim) {
                    return ScaleTransition(child: child, scale: anim);
                  },
                  switchInCurve: Curves.fastLinearToSlowEaseIn,
                  switchOutCurve: Curves.fastOutSlowIn,
                  duration: Duration(milliseconds: 300),
                  child: playId == musicInfoModels[index].id
                      ? RotateTransform(
                          animation: animation,
                          //将要执行动画的子view
                          child: Container(
                            height: 60.0,
                            width: 60.0,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(30.0),
                              image: DecorationImage(
                                fit: BoxFit.fill, //这个地方很重要，需要设置才能充满
                                image: FileManager.musicAlbumPictureImage(
                                    musicInfoModels[index].artist,
                                    musicInfoModels[index].album),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          height: 60.0,
                          width: 60.0,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8.0),
                            image: DecorationImage(
                              fit: BoxFit.fill, //这个地方很重要，需要设置才能充满
                              image: FileManager.musicAlbumPictureImage(
                                  musicInfoModels[index].artist,
                                  musicInfoModels[index].album),
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
                            Flex(
                              direction: Axis.horizontal,
                              children: <Widget>[
                                Icon(
                                  CupertinoIcons.heart_solid,
                                  color: Colors.red,
                                  size: 16,
                                ),
                              ],
                            ),
                            const Padding(padding: EdgeInsets.only(right: 5.0)),
                            Expanded(
                              child: Text(
                                musicInfoModels[index].name,
                                maxLines: 1,
                                style: themeData.primaryTextTheme.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.only(top: 8.0)),
                        Text(
                          musicInfoModels[index].fullpath,
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

    return row;
  }
}
