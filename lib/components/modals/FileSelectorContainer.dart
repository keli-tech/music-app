import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/services/Database.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class FileSelectorContainer extends StatefulWidget {
  FileSelectorContainer(
      {Key key,
      this.title,
      this.musicInfoModel,
      this.playListId,
      this.level,
      this.statusBarHeight})
      : super(key: key);

  MusicInfoModel musicInfoModel;
  int playListId;
  String title;
  double statusBarHeight;
  int level = 0;

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
    double _windowHeight = MediaQuery.of(context).size.height;
    return Container(
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        ListTile(
          title: Text(widget.title),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(
              CupertinoIcons.clear_circled_solid,
              color: Colors.grey,
              size: 30,
            ),
            onPressed: () {
//              Navigator.of(context).pop();
              for (int i = 0; i <= widget.level; i++) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        new Divider(color: Colors.grey),
        Flexible(
          child: Container(
            child: Scrollbar(
              child: ListView(
//          reverse: _reverse,
                scrollDirection: Axis.vertical,
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
        ),
      ]),
    );
  }

  // 文件夹
  Widget buildFoldListTile(_ListItem _listItem) {
    ThemeData themeData = Theme.of(context);
    Widget listTile;
    listTile = ListTile(
      onTap: () {
        showCupertinoModalBottomSheet(
          expand: true,
          elevation: 30,
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context, scrollController) => Material(
            color: Color(0xffececec),
            child: SafeArea(
              top: false,
              child: FileSelectorContainer(
                level: widget.level + 1,
                playListId: widget.playListId,
                title: _listItem.musicInfoModel.name,
                musicInfoModel: _listItem.musicInfoModel,
              ),
            ),
          ),
        );
      },
      key: Key(_listItem.musicInfoModel.id.toString()),
      isThreeLine: false,
//      title: Text(""),
      title: Row(
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
      isThreeLine: false,
      checkColor: themeData.primaryColorLight,
      activeColor: themeData.primaryColorDark,
      value: _listItem.checkState ?? false,
      onChanged: (bool newChecked) {
        if (newChecked) {
          DBProvider.db
              .addMusicToPlayList(
                  widget.playListId, _listItem.musicInfoModel.id)
              .then((res) {
            if (res > 0) {
//              ToastUtils.show("已添加到歌单");
            }
          });
        } else {
          DBProvider.db
              .deleteMusicFromPlayList(
                  widget.playListId, _listItem.musicInfoModel.id)
              .then((res) {
//            if (res > 0) ToastUtils.show("已从歌单删除.");
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
              fit: BoxFit.fill,
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
