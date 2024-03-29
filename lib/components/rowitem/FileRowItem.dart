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
import 'package:just_audio/just_audio.dart';

// 文件中的列
class FileRowItem extends StatelessWidget {
  const FileRowItem({
    required this.lastItem,
    required this.statusBarHeight,
    required this.index,
    required this.mplID,
    required this.musicInfoModels,
    required this.musicInfoFavIDSet,
    required this.audioPlayerState,
    required this.playId,
  });

  final bool lastItem;
  final int mplID;

  final int index;
  final double statusBarHeight;
  final List<MusicInfoModel> musicInfoModels;
  final PlayerState audioPlayerState;
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
            fullpath: musicInfoModels[index].fullpath,
            name: musicInfoModels[index].name,
            // colorName: colorName,
            // index: index,
          ),
        ));
      },
      child: Tile(
        selected:
            playId == musicInfoModels[index].id && audioPlayerState.playing,
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
                                style: themeData.primaryTextTheme.headline6,
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
                    showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context1) {
                        return _actionSheet(context1, context);
                      },
                    );
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
      padding: EdgeInsets.only(top: 5),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          MusicControlService.play(context, musicInfoModels, index);
        },
        child: Tile(
          radiusnum: 15.0,
          selected:
              playId == musicInfoModels[index].id && audioPlayerState.playing,
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
                                audioPlayerState.playing
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
                                          audioPlayerState.playing
                                      ? themeData.textTheme.subtitle2
                                      : themeData.primaryTextTheme.headline6,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const Padding(padding: EdgeInsets.only(top: 8.0)),
                          Text(
                            musicInfoModels[index].filesize,
                            style: playId == musicInfoModels[index].id &&
                                    audioPlayerState.playing
                                ? themeData.textTheme.subtitle2
                                : themeData.primaryTextTheme.subtitle2,
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
                              audioPlayerState.playing
                          ? themeData.primaryColorLight
                          : themeData.primaryColorDark,
                    ),
                    onPressed: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context1) {
                          return _actionSheet(context1, context);
                        },
                      );
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

  Widget _actionSheet(BuildContext context1, BuildContext context) {
    ThemeData themeData = Theme.of(context);
    var windowHeight = MediaQuery.of(context).size.height;
    List<Widget> actionSheets = [];

    actionSheets.add(CupertinoActionSheetAction(
      child: Text(
        '收藏到歌单',
      ),
      onPressed: () {
        Navigator.pop(context1);

        showModalBottomSheet<void>(
            context: context,
            useRootNavigator: false,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return PlayListSelectorContainer(
                title: "收藏到歌单",
                mid: musicInfoModels[index].id,
                statusBarHeight: statusBarHeight,
                musicInfoModel: musicInfoModels[index],
              );
            });

//        showCupertinoModalPopup(
//            context: context,
//            builder: (BuildContext context) {
//              return PlayListSelectorContainer(
//                title: "添加到歌单",
//                playListId: mplID,
//                statusBarHeight: statusBarHeight,
//              );
//            });
      },
    ));
    actionSheets.add(CupertinoActionSheetAction(
        child: Text(
          '删除音乐文件',
        ),
        isDestructiveAction: true,
        onPressed: () {
          Navigator.of(context1).pop();

          showCupertinoDialog<String>(
            context: context1,
            builder: (BuildContext context1) => CupertinoAlertDialog(
              title: const Text('删除确认'),
              content: Text('是否删除\"' + musicInfoModels[index].fullpath + '\"?'),
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
                      FileManager.musicFile(musicInfoModels[index].fullpath)
                          .delete();

                      ToastUtils.show("已删除文件");

                      Navigator.pop(context1);
                    });
                  },
                ),
              ],
            ),
          ).then((String? value) {
            // setState(() {
            //   lastSelectedValue = value;
            // });
          });
        }));

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
}
