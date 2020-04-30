import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/models/MusicPlayListModel.dart';
import 'package:hello_world/services/Database.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:hello_world/utils/ToastUtils.dart';

class PlayListSelectorContainer extends StatefulWidget {
  PlayListSelectorContainer(
      {Key key,
      this.title,
      this.musicInfoModel,
      this.mid,
      this.statusBarHeight})
      : super(key: key);

  MusicInfoModel musicInfoModel;
  String title;
  int mid;
  double statusBarHeight;

  @override
  _PlayListSelectorContainer createState() => _PlayListSelectorContainer();
}

class _PlayListSelectorContainer extends State<PlayListSelectorContainer>
    with SingleTickerProviderStateMixin {
  List<MusicPlayListModel> _musicPlayListModels = [];

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
    // todo 把本歌单id从列表中删除
    DBProvider.db
        .getMusicPlayListByType(MusicPlayListModel.TYPE_PLAY_LIST)
        .then((onValue) async {
      setState(() {
        _musicPlayListModels = onValue;
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
              Navigator.of(context).pop();
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
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                children: _musicPlayListModels.map<Widget>((item) {
                  return ListTile(
                    contentPadding:
                        EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 2),
                    leading: Container(
                        key: Key("start"),
                        height: 50.0,
                        width: 50.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: FileManager.musicAlbumPictureImage(
                                  item.artist, item.imgpath),
                            ))),
                    isThreeLine: false,
                    title: Text(
                      item.name,
                      style: themeData.textTheme.title,
                    ),
                    onTap: () {
                      DBProvider.db
                          .addMusicToPlayList(item.id, widget.mid)
                          .then((onValue) {
                        if (onValue > 0) {
                          ToastUtils.show("收藏成功");
                        }
                      });

                      Navigator.of(context).pop();
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
