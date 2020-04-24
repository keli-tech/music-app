import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hello_world/components/FileSelectorComp.dart';
import 'package:hello_world/services/FileManager.dart';

import '../models/MusicInfoModel.dart';
import '../services/Database.dart';

class FileSelectorContainer extends StatefulWidget {
  FileSelectorContainer(
      {Key key,
      this.title,
      this.musicInfoModel,
      this.playListId,
      this.statusBarHeight})
      : super(key: key);

  MusicInfoModel musicInfoModel;
  int playListId;
  String title;
  double statusBarHeight;

  @override
  _FileSelectorContainer createState() => _FileSelectorContainer();
}

class _FileSelectorContainer extends State<FileSelectorContainer>
    with SingleTickerProviderStateMixin {
  List<MusicInfoModel> _musicInfoModelsUnderPlayList = [];

  List<_ListItem> listItems = [];

  @override
  void initState() {
    super.initState();

    _refreshList();
  }

  //销毁
  @override
  void dispose() {
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

    return Container(
      color: themeData.backgroundColor,
      padding: EdgeInsetsDirectional.only(top: widget.statusBarHeight),
      child: Column(
        children: <Widget>[
          Flexible(
            child: CupertinoTabView(
                builder: (BuildContext context) => buildWidget(context)),
          ),
        ],
      ),

//          CupertinoTabView(
//              builder: (BuildContext context) => buildWidget(context))
    );
  }

  Widget buildWidget(BuildContext buildContext) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: themeData.backgroundColor,
      appBar: CupertinoNavigationBar(
        backgroundColor: themeData.backgroundColor,
        leading: Container(
            width: 50,
            height: 50,
            child: FlatButton(
              padding: EdgeInsets.only(left: 0, right: 0),
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 40,
                color: themeData.primaryColor,
              ),
              onPressed: () {
                print(1);
                Navigator.of(context).pop();
              },
            )),
        middle: Text(
          widget.title,
          style: themeData.primaryTextTheme.headline,
        ),
        trailing: Container(
            width: 50,
            height: 50,
            child: FlatButton(
              padding: EdgeInsets.only(left: 0, right: 0),
              child: Text(
                "完成",
                style: themeData.primaryTextTheme.title,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )),
      ),
      body: Scrollbar(
        child: ListView(
//          reverse: _reverse,
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          children: listItems.map<Widget>((item) {
            if (item.musicInfoModel.type ==  MusicInfoModel.TYPE_FOLD) {
              return buildFoldListTile(item);
            } else {
              return buildListTile(item);
            }
          }).toList(),
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
        Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (BuildContext context) => FileSelectorComp(
            level: 1,
            playListId: widget.playListId,
            title: _listItem.musicInfoModel.name,
            musicInfoModel: _listItem.musicInfoModel,
          ),
        ));
      },
      key: Key(_listItem.musicInfoModel.id.toString()),
      isThreeLine: true,
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

  //文件
  Widget buildListTile(_ListItem _listItem) {
    ThemeData themeData = Theme.of(context);

    Widget listTile = CheckboxListTile(
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
          Expanded(
            child: Text(
              _listItem.musicInfoModel.type != MusicInfoModel.TYPE_FOLD
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
