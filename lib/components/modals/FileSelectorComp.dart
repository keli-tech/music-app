import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:hello_world/utils/ToastUtils.dart';

import '../../models/MusicInfoModel.dart';
import '../../services/Database.dart';

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
  List<MusicInfoModel> _musicInfoModelsUnderPlayList = [];

  var _eventBusOn;
  bool _isLoding = false;
  List<_ListItem> listItems = [];

  @override
  void initState() {
    super.initState();

    _refreshList();
  }

  //销毁
  @override
  void dispose() {
    this._eventBusOn.cancel();
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
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(
              Icons.keyboard_arrow_left,
              size: 40,
              color: themeData.primaryColor,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          middle: Text(
            widget.title,
            style: themeData.primaryTextTheme.headline6,
          ),
          trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                for (int i = 0; i <= widget.level; i++) {
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                "完成",
                style: themeData.primaryTextTheme.headline6,
              )),
        ),
        body: Scrollbar(
          child: ListView(
//          reverse: _reverse,
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            children: listItems.map<Widget>((item) {
              if (item.musicInfoModel.type == MusicInfoModel.TYPE_FOLD) {
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
      isThreeLine: false,
//      value: _listItem.checkState ?? false,
      title: Text(""),
      subtitle: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              '${_listItem.musicInfoModel.name}',
              maxLines: 1,
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
        ),
      ),
    );

    return listTile;
  }

  Widget buildListTile(_ListItem _listItem) {
    ThemeData themeData = Theme.of(context);

    Widget listTile;

    listTile = CheckboxListTile(
      key: Key(_listItem.musicInfoModel.id.toString()),
      isThreeLine: false,
      activeColor: themeData.primaryColor,
      value: _listItem.checkState ?? false,
      onChanged: (bool newChecked) {
        if (newChecked) {
          DBProvider.db
              .addMusicToPlayList(
                  widget.playListId, _listItem.musicInfoModel.id)
              .then((res) {
            if (res > 0) {
              ToastUtils.show("已添加到歌单");
            }
          });
        } else {
          DBProvider.db
              .deleteMusicFromPlayList(
                  widget.playListId, _listItem.musicInfoModel.id)
              .then((res) {
            if (res > 0) ToastUtils.show("已从歌单删除.");
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
              _listItem.musicInfoModel.type != MusicInfoModel.TYPE_FOLD
                  ? '${_listItem.musicInfoModel.name}'
                  : "sdsdff",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      subtitle: Text(
        '${_listItem.musicInfoModel.album} - ${_listItem.musicInfoModel.artist}',
      ),
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
