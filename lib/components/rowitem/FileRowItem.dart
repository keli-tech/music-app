import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/components/Tile.dart';
import 'package:hello_world/components/modals/PlayListSelectorContainer.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/screens/file/FileList2Screen.dart';
import 'package:hello_world/services/Database.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:hello_world/services/MusicControlService.dart';
import 'package:hello_world/utils/ToastUtils.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class FileRowItem extends StatelessWidget {
  const FileRowItem({
    this.lastItem,
    this.statusBarHeight,
    this.index,
    this.mplID,
    this.musicInfoModels,
    this.musicInfoFavIDSet,
    this.audioPlayerState,
    this.playId,
  });

  final bool lastItem;
  final int mplID;

  final int index;
  final double statusBarHeight;
  final List<MusicInfoModel> musicInfoModels;
  final AudioPlayerState audioPlayerState;
  final Set<int> musicInfoFavIDSet;

  final int playId;

  @override
  Widget build(BuildContext context) {
    var row;
    if (musicInfoModels[index].type == MusicInfoModel.TYPE_FOLD) {
      row = builderFold(context);
    } else {
      row = builder(context);
    }

    return row;
    if (lastItem) {
      return row;
    }

    return Column(
      children: <Widget>[
        row,
        const Divider(
          thickness: 0.5,
          indent: 70,
          endIndent: 20,
          height: 0.40,
        ),
      ],
    );
  }

  Widget builderFold(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    final Widget row = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute<void>(
          title: musicInfoModels[index].name,
          builder: (BuildContext context) => FileList2Screen(
            musicInfoModel: musicInfoModels[index],
            // colorName: colorName,
            // index: index,
          ),
        ));
      },
      child: Tile(
        selected: playId == musicInfoModels[index].id &&
            audioPlayerState == AudioPlayerState.PLAYING,
        radiusnum: 15.0,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(
                left: 16.0, top: 8.0, bottom: 8.0, right: 8.0),
            child: Row(
              children: <Widget>[
                Container(
                  height: 50.0,
                  width: 50.0,
                  child: Icon(
                    Icons.folder,
                    size: 50,
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
                    _actionSheet(context);
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

    final Widget row = Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          MusicControlService.play(context, musicInfoModels, index);
        },
        child: Tile(
          radiusnum: 15.0,
          selected: playId == musicInfoModels[index].id &&
              audioPlayerState == AudioPlayerState.PLAYING,
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
                      child: Container(
                        height: 50.0,
                        width: 50.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          image: DecorationImage(
                            fit: BoxFit.fill, //这个地方很重要，需要设置才能充满
                            image: FileManager.musicAlbumPictureImage(
                                musicInfoModels[index].artist,
                                musicInfoModels[index].album),
                          ),
                        ),
                        child: playId == musicInfoModels[index].id &&
                                audioPlayerState == AudioPlayerState.PLAYING
                            ? Container(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  key: Key("start"),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.0),
                                    color: Colors.black54,
                                  ),
                                  child: new Image.asset(
                                    "assets/images/playing.gif",
                                    width: 50,
                                  ),
                                ),
                              )
                            : Container(),
                      )),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              !musicInfoFavIDSet
                                      .contains(musicInfoModels[index].id)
                                  ? Text("")
                                  : Flex(
                                      direction: Axis.horizontal,
                                      children: <Widget>[
                                        Icon(
                                          CupertinoIcons.heart_solid,
                                          color: Colors.red,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                              Expanded(
                                child: Text(
                                  musicInfoModels[index].name,
                                  maxLines: 1,
                                  style: playId == musicInfoModels[index].id &&
                                          audioPlayerState ==
                                              AudioPlayerState.PLAYING
                                      ? themeData.textTheme.subtitle
                                      : themeData.primaryTextTheme.title,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const Padding(padding: EdgeInsets.only(top: 8.0)),
                          Text(
                            musicInfoModels[index].filesize ?? "",
                            style: playId == musicInfoModels[index].id &&
                                    audioPlayerState == AudioPlayerState.PLAYING
                                ? themeData.textTheme.subtitle
                                : themeData.primaryTextTheme.subtitle,
                          ),
                        ],
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Icon(
                      Icons.more_horiz,
                      semanticLabel: 'Add',
                      color: playId == musicInfoModels[index].id &&
                              audioPlayerState == AudioPlayerState.PLAYING
                          ? themeData.primaryColorLight
                          : themeData.primaryColorDark,
                    ),
                    onPressed: () {
                      _actionSheet(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return row;
  }

  _actionSheet(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    showCupertinoModalBottomSheet(
      useRootNavigator: true,
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
              title: Text(musicInfoModels[index].name),
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
            Divider(color: Colors.grey),
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
                      Expanded(
                          child: Text(
                        '收藏到歌单',
                      )),
                      Icon(
                        Icons.favorite,
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
                        child: PlayListSelectorContainer(
                          title: "收藏到歌单",
                          mid: musicInfoModels[index].id,
                          statusBarHeight: statusBarHeight,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            new Divider(),
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
                      Expanded(
                          child: Text(
                        '删除音乐文件',
                        style: TextStyle(
                          color: themeData.errorColor,
                        ),
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
                    builder: (BuildContext context1) => CupertinoAlertDialog(
                      title: const Text('删除确认'),
                      content: Text(
                          '是否删除\"' + musicInfoModels[index].fullpath + '\"?'),
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
                            DBProvider.db
                                .deleteMusic(musicInfoModels[index].id)
                                .then((onValue) {
                              FileManager.musicFile(
                                      musicInfoModels[index].fullpath)
                                  .delete();

                              ToastUtils.show("已删除文件");

                              Navigator.pop(context1);
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
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 130),
            ),
          ]),
        ),
      ),
    );
  }
}
