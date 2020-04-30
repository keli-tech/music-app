import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:hello_world/components/modals/FileSelectorContainer.dart';
import 'package:hello_world/components/rowitem/MusicRowItem.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/models/MusicPlayListModel.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:hello_world/utils/ToastUtils.dart';
import 'package:image/image.dart' as ImageImage;
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import '../../models/MusicInfoModel.dart';
import '../../services/Database.dart';

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

    _chatTextController = TextEditingController(
      text: widget.musicPlayListModel.name,
    );

    _refreshList();
  }

  @override
  void deactivate() {
    super.deactivate();
    _logger.info("deactivate");
    _refreshList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _refreshList() {
    int plid = widget.musicPlayListModel.id;
    DBProvider.db.getMusicInfoByPlayListId(plid).then((onValue) {
      File image;
      if (widget.musicPlayListModel.type == MusicPlayListModel.TYPE_PLAY_LIST) {
        image = FileManager.musicAlbumPictureFile(
            widget.musicPlayListModel.artist,
            widget.musicPlayListModel.imgpath);
      } else if (widget.musicPlayListModel.type ==
          MusicPlayListModel.TYPE_FAV) {
        image = FileManager.musicAlbumPictureFile(
            widget.musicPlayListModel.artist,
            widget.musicPlayListModel.imgpath);
      } else {
        image = FileManager.musicAlbumPictureFile(
            widget.musicPlayListModel.artist, widget.musicPlayListModel.name);
      }

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
        border: null,
        backgroundColor: themeData.backgroundColor,
        middle: Text(
          widget.musicPlayListModel.name,
          style: themeData.primaryTextTheme.title,
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            Icons.more_vert,
            color: themeData.primaryColor,
          ),
          onPressed: () {
            _actionSheet(context);
          },
        ),
      ),
      child: CustomScrollView(
        semanticChildCount: _musicInfoModels.length,
        slivers: <Widget>[
          _image == null || !_image.existsSync()
              ? SliverPadding(
                  padding:
                      EdgeInsets.only(left: 0, top: 10, right: 0, bottom: 1),
                )
              : SliverAppBar(
                  automaticallyImplyLeading: false,
                  forceElevated: true,
                  elevation: 5,
                  stretch: true,
                  backgroundColor: themeData.backgroundColor,
                  expandedHeight: width * 0.8,
                  flexibleSpace: Hero(
                    tag: widget.musicPlayListModel.id,
                    child: Container(
//                padding: EdgeInsets.only(left: 70, top: 0, right: 0, bottom: 70),
                      decoration: new BoxDecoration(
                        color: Colors.white.withOpacity(0.0),
                        image: new DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(_image),
                        ),
                      ),
                    ),
                  ),
                ),
          Consumer<MusicInfoData>(
            builder: (context, musicInfoData, _) => SliverPadding(
              padding:
                  EdgeInsets.only(left: 15, top: 10, right: 15, bottom: 70),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return MusicRowItem(
                      statusBarHeight: _statusBarHeight,
                      lastItem: index == _musicInfoModels.length - 1,
                      index: index,
                      mplID: widget.musicPlayListModel.id,
                      musicInfoModels: _musicInfoModels,
                      playId: musicInfoData.musicInfoModel.id,
                      audioPlayerState: musicInfoData.audioPlayerState,
                      musicInfoFavIDSet: musicInfoData.musicInfoFavIDSet,
                      refreshFunction: _refreshList,
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

  _actionSheet(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    showCupertinoModalBottomSheet(
      expand: true,
      elevation: 30,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context, scrollController) => Material(
        color: Color(0xffececec),
        child: SafeArea(
          top: false,
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            ListTile(
              title: Text(widget.musicPlayListModel.name),
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white),
                  padding: EdgeInsets.only(left: 15, right: 15),
                  height: 50,
                  child: Row(
                    children: <Widget>[
                      Expanded(child: Text("添加歌曲")),
                      Icon(
                        Icons.create_new_folder,
                        color: Colors.black45,
                        size: 30,
                      ),
                    ],
                  ),
                ),
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
                          level: 0,
                          title: "添加歌曲",
                          playListId: widget.musicPlayListModel.id,
                          statusBarHeight: widget.statusBarHeight,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            new Divider(),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white),
                padding: EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  children: <Widget>[
                    widget.musicPlayListModel.type !=
                            MusicPlayListModel.TYPE_ALBUM
                        ? GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.white),
                              height: 50,
                              child: Row(
                                children: <Widget>[
                                  Expanded(child: Text("更换封面")),
                                  Icon(
                                    Icons.photo_album,
                                    color: Colors.black45,
                                    size: 30,
                                  ),
                                ],
                              ),
                            ),
                            onTap: () async {
                              Navigator.of(context).pop();
                              File imageFile = await ImagePicker.pickImage(
                                  source: ImageSource.gallery);

                              if (imageFile != null) {
                                var updateValue = {
                                  "imgpath": widget.musicPlayListModel.name +
                                      (new DateTime.now()
                                              .millisecondsSinceEpoch)
                                          .toString(),
                                };
                                DBProvider.db
                                    .updateMusicPlayList(
                                        widget.musicPlayListModel.id,
                                        updateValue)
                                    .then((onValue) async {
                                  if (onValue <= 0) {
                                    _logger.warning("error $onValue");
                                  } else {
                                    try {
                                      var oldFile =
                                          FileManager.musicAlbumPictureFile(
                                              "-",
                                              widget
                                                  .musicPlayListModel.imgpath);
                                      if (oldFile.existsSync()) {
                                        oldFile.deleteSync();
                                      }
                                    } catch (error) {
                                      _logger.warning(error);
                                    }
                                    if (imageFile != null) {
                                      setState(() {
                                        _image = imageFile;
                                      });
                                    }
                                    ImageImage.Image image =
                                        ImageImage.decodeImage(
                                            imageFile.readAsBytesSync());
                                    ImageImage.Image thumbnail =
                                        ImageImage.copyResize(image,
                                            width: 800);
                                    FileManager.musicAlbumPicturePath(
                                            "-", updateValue["imgpath"])
                                        .create(recursive: true);
                                    var imageFileReal =
                                        FileManager.musicAlbumPictureFile(
                                            "-", updateValue["imgpath"]);

                                    imageFileReal.writeAsBytes(
                                        ImageImage.encodePng(thumbnail));
                                  }
                                });
                              }
                            },
                          )
                        : Container(),
                    widget.musicPlayListModel.id !=
                                MusicPlayListModel.FAVOURITE_PLAY_LIST_ID &&
                            widget.musicPlayListModel.type !=
                                MusicPlayListModel.TYPE_ALBUM
                        ? GestureDetector(
                            child: Container(
                              height: 50,
                              child: Row(
                                children: <Widget>[
                                  Expanded(child: Text("重新命名")),
                                  Icon(
                                    Icons.text_fields,
                                    color: Colors.black45,
                                    size: 30,
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _updatePlayListName();
                            },
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
            widget.musicPlayListModel.id !=
                        MusicPlayListModel.FAVOURITE_PLAY_LIST_ID &&
                    widget.musicPlayListModel.type !=
                        MusicPlayListModel.TYPE_ALBUM
                ? Divider()
                : Container(),
            widget.musicPlayListModel.type != MusicPlayListModel.TYPE_FAV
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white),
                        padding: EdgeInsets.only(left: 15, right: 15),
                        height: 50,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                                child: Text(
                              '删除' +
                                  (widget.musicPlayListModel.type ==
                                          MusicPlayListModel.TYPE_ALBUM
                                      ? "专辑"
                                      : "歌单"),
                              style: TextStyle(color: themeData.errorColor),
                            )),
                            Icon(
                              Icons.delete_forever,
                              color: Colors.black45,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();

                        showCupertinoDialog<String>(
                          context: context,
                          builder: (BuildContext context1) =>
                              CupertinoAlertDialog(
                            title: const Text('删除确认'),
                            content: Text('是否删除\"' +
                                widget.musicPlayListModel.name +
                                '\"?'),
                            actions: <Widget>[
                              CupertinoDialogAction(
                                child: Text(
                                  '取消',
                                ),
                                isDefaultAction: true,
                                onPressed: () =>
                                    Navigator.pop(context1, 'Cancel'),
                              ),
                              CupertinoDialogAction(
                                child: Text(
                                  '删除',
                                ),
                                isDestructiveAction: true,
                                onPressed: () {
                                  Navigator.pop(context1);

                                  DBProvider.db
                                      .deleteMusicPlayList(
                                          widget.musicPlayListModel.id)
                                      .then((onValue) {
                                    ToastUtils.show("已删除歌单");
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
                    ),
                  )
                : Container(),
            Padding(
              padding: EdgeInsets.only(bottom: 130),
            ),
          ]),
        ),
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
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 0.0,
                    color: CupertinoColors.inactiveGray,
                  ),
                  color: Colors.white,
                ),
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
