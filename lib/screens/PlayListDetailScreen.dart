import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hello_world/components/FileSelectorContainer.dart';
import 'package:hello_world/components/MusicRowItem.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/models/MusicPlayListModel.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:hello_world/utils/ToastUtils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../models/MusicInfoModel.dart';
import '../services/Database.dart';

// 我喜欢的音乐
// 播放列表
// 专辑
class PlayListDetailScreen extends StatefulWidget {
  PlayListDetailScreen({Key key, this.musicPlayListModel, this.statusBarHeight})
      : super(key: key);
  static const String routeName = '/playlist/detail';

  @override
  _PlayListDetailScreen createState() => _PlayListDetailScreen();

  double statusBarHeight;

  MusicPlayListModel musicPlayListModel;
}

class _PlayListDetailScreen extends State<PlayListDetailScreen>
    with SingleTickerProviderStateMixin {
  List<MusicInfoModel> _musicInfoModels = [];
  File _image;
  Logger _logger = new Logger("PlayListDetailScreen");
  TextEditingController _chatTextController;

  @override
  void initState() {
    super.initState();

    _chatTextController = TextEditingController();
    _chatTextController.text = widget.musicPlayListModel.name;

    _refreshList();
  }

  @override
  void deactivate() {
    super.deactivate();
    _logger.info("deactivate");

    _refreshList();
  }

  _refreshList() async {
    int plid = widget.musicPlayListModel.id;
    DBProvider.db.getMusicInfoByPlayListId(plid).then((onValue) {
      File image = FileManager.musicAlbumPictureFile(
          widget.musicPlayListModel.artist, widget.musicPlayListModel.imgpath);

      setState(() {
        _musicInfoModels = onValue;
        _image = image;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final _statusBarHeight = MediaQuery.of(context).padding.top;

    ThemeData themeData = Theme.of(context);
    return CupertinoPageScaffold(
      backgroundColor: themeData.backgroundColor,
      navigationBar: CupertinoNavigationBar(
        trailing: CupertinoButton(
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
      child: CustomScrollView(
        semanticChildCount: _musicInfoModels.length,
        slivers: <Widget>[
          SliverAppBar(
            brightness: Brightness.light,
            automaticallyImplyLeading: false,
            forceElevated: true,
            elevation: 5,
            stretch: true,
            backgroundColor: Colors.white70,
            expandedHeight: width * 0.7,
            flexibleSpace: Hero(
              tag: widget.musicPlayListModel.id,
              child: Container(
                padding: EdgeInsets.only(top: _statusBarHeight),
                child: new Container(
                  decoration: new BoxDecoration(
                    color: Colors.white.withOpacity(0.0),
                    image: new DecorationImage(
                      fit: BoxFit.cover,
                      image: _image == null
                          ? FileManager.musicAlbumPictureImage("1", "1")
                          : FileImage(_image),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Consumer<MusicInfoData>(
            builder: (context, musicInfoData, _) => SliverPadding(
              // Top media padding consumed by CupertinoSliverNavigationBar.
              // Left/Right media padding consumed by Tab1RowItem.
              padding: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 70),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return MusicRowItem(
                      index: index,
                      musicInfoModels: _musicInfoModels,
                      playId: musicInfoData.musicInfoModel.id,
                      audioPlayerState: musicInfoData.audioPlayerState,
                      musicInfoFavIDSet: musicInfoData.musicInfoFavIDSet,
                    );
                  },
                  childCount: _musicInfoModels.length,
                ),
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

    if (widget.musicPlayListModel.id !=
        MusicPlayListModel.FAVOURITE_PLAY_LIST_ID) {
      actionSheets.add(CupertinoActionSheetAction(
        child: Text(
          '重新命名',
        ),
        onPressed: () {
          Navigator.pop(context1);
          _updatePlayListName();
        },
      ));
    }

    actionSheets.add(CupertinoActionSheetAction(
      child: Text(
        '更换封面',
      ),
      onPressed: () async {
        Navigator.pop(context1);
        var image = await ImagePicker.pickImage(source: ImageSource.gallery);

        if (image != null) {
          var updateValue = {
            "imgpath": widget.musicPlayListModel.name +
                (new DateTime.now().millisecondsSinceEpoch).toString(),
          };
          DBProvider.db
              .updateMusicPlayList(widget.musicPlayListModel.id, updateValue)
              .then((onValue) {
            var oldFile = FileManager.musicAlbumPictureFile(
                "-", widget.musicPlayListModel.imgpath);
            if (oldFile != null) {
              oldFile.deleteSync();
            }

            image.copySync(FileManager.musicAlbumPictureFullPath(
                    "-", updateValue["imgpath"])
                .path);

            setState(() {
              _image = image;
            });
          });
        }
      },
    ));

    if (widget.musicPlayListModel.id !=
        MusicPlayListModel.FAVOURITE_PLAY_LIST_ID) {
      actionSheets.add(CupertinoActionSheetAction(
        child: Text(
          '删除歌单',
        ),
        isDestructiveAction: true,
        onPressed: () {
          Navigator.pop(context1, 'Discard');

          showCupertinoDialog<String>(
            context: context1,
            builder: (BuildContext context1) => CupertinoAlertDialog(
              title: const Text('删除确认'),
              content: Text('是否删除\"' + widget.musicPlayListModel.name + '\"?'),
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
                    '删除',
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
                          gravity: ToastGravity.CENTER,
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
        ),
        onPressed: () {
          Navigator.of(context1).pop();
        },
      ),
    );
  }

  _updatePlayListName() {
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

                      var updateValue = {
                        "name": _chatTextController.text.trim(),
                      };
                      int newPlid = await DBProvider.db.updateMusicPlayList(
                          widget.musicPlayListModel.id, updateValue);
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
