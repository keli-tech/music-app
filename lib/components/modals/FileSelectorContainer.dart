import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hello_world/components/modals/FileSelectorComp.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/services/Database.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:hello_world/utils/ToastUtils.dart';

class FileSelectorContainer extends StatefulWidget {
  FileSelectorContainer(
      {Key? key,
      required this.title,
      this.musicInfoModel,
      required this.playListId,
      required this.statusBarHeight})
      : super(key: key);

  MusicInfoModel? musicInfoModel;
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
      fullpath = widget.musicInfoModel?.fullpath ?? "";
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
          widget.title,
          style: themeData.primaryTextTheme.headline6,
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text(
            "完成",
            style: themeData.primaryTextTheme.headline6,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
            containerContext: context,
          ),
        ));
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
      activeColor: themeData.primaryColor,
      value: _listItem.checkState ,
      onChanged: (bool? newChecked) {
        if (newChecked ?? false) {
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
          _listItem.checkState = newChecked ?? false;
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
              fit: BoxFit.fill, //这个地方很重要，需要设置才能充满
              image: FileManager.musicAlbumPictureImage(
                  _listItem.musicInfoModel.artist,
                  _listItem.musicInfoModel.album )),
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
