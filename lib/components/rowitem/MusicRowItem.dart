import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/components/modals/PlayListSelectorContainer.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/services/Database.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:hello_world/services/MusicControlService.dart';
import 'package:hello_world/utils/ToastUtils.dart';

class MusicRowItem extends StatelessWidget {
  const MusicRowItem({
    this.mplID,
    this.index,
    this.lastItem,
    this.musicInfoModels,
    this.playId,
    this.audioPlayerState,
    this.musicInfoFavIDSet,
    this.refreshFunction,
    this.statusBarHeight,
  });

  final bool lastItem;
  final int mplID;
  final int index;
  final double statusBarHeight;
  final List<MusicInfoModel> musicInfoModels;
  final int playId;
  final AudioPlayerState audioPlayerState;
  final Set<int> musicInfoFavIDSet;
  final Function() refreshFunction;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    MusicInfoModel _musicInfoModel = musicInfoModels[index];

    final Widget row = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        MusicControlService.play(context, musicInfoModels, index);
      },
      child: Container(
        color: playId == musicInfoModels[index].id &&
                audioPlayerState == AudioPlayerState.PLAYING
            ? themeData.selectedRowColor
            : themeData.cardColor,
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
                              _musicInfoModel.artist, _musicInfoModel.album)),
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
                                color: Colors.black45,
                              ),
                              child: new Image.asset(
                                "assets/images/playing.gif",
                                width: 50,
                              ),
                            ),
                          )
                        : Container(),
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
                            !musicInfoFavIDSet.contains(_musicInfoModel.id)
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
                                _musicInfoModel.type != MusicInfoModel.TYPE_FOLD
                                    ? '${_musicInfoModel.title} - ${_musicInfoModel.artist}'
                                    : "",
                                style: themeData.primaryTextTheme.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.only(top: 8.0)),
                        Text(
                          _musicInfoModel.type != MusicInfoModel.TYPE_FOLD
                              ? '${_musicInfoModel.album}'
                              : "",
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

    if (lastItem) {
      return row;
    }

    return Column(
      children: <Widget>[
        row,
        const Divider(
          thickness: 0.5,
          endIndent: 20,
          indent: 70,
          height: 0.40,
        ),
      ],
    );
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
    if (mplID != null && mplID > 0) {
      actionSheets.add(CupertinoActionSheetAction(
        child: Text(
          '从歌单删除',
        ),
        isDestructiveAction: true,
        onPressed: () {
          Navigator.of(context1).pop();

          DBProvider.db
              .deleteMusicFromPlayList(mplID, musicInfoModels[index].id)
              .then((onValue) {
            if (onValue > 0) {
              refreshFunction();
              ToastUtils.show("已从歌单删除.");
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
}
