import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/screens/FileList2Screen.dart';
import 'package:hello_world/screens/MyHttpServer.dart';
import 'package:hello_world/services/EventBus.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:provider/provider.dart';

class FileRowItem extends StatelessWidget {
  const FileRowItem({
    this.index,
    this.musicInfoModels,
    this.musicInfoFavIDSet,
    this.audioPlayerState,
    this.playId,
  });

  final int index;
  final List<MusicInfoModel> musicInfoModels;
  final AudioPlayerState audioPlayerState;
  final Set<int> musicInfoFavIDSet;

  final int playId;

  @override
  Widget build(BuildContext context) {
    if (musicInfoModels[index].type == MusicInfoModel.TYPE_FOLD) {
      return builderFold(context);
    } else {
      return builder(context);
    }
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
      child: Container(
        color:
            CupertinoDynamicColor.resolve(themeData.backgroundColor, context),
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
                            const Padding(padding: EdgeInsets.only(right: 5.0)),
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
                        const Padding(padding: EdgeInsets.only(top: 8.0)),
                        Text(
                          musicInfoModels[index].fullpath,
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
                    Navigator.of(context).push(CupertinoPageRoute<void>(
                      title: "hehe2",
                      builder: (BuildContext context) => MyHttpServer(
                          // color: color,
                          // colorName: colorName,
                          // index: index,
                          ),
                    ));
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
    MusicInfoModel _musicInfoModel = musicInfoModels[index];
    List<MusicInfoModel> mims =
        musicInfoModels.getRange(0, musicInfoModels.length).toList();
    mims.removeWhere((music) {
      return music.type ==  MusicInfoModel.TYPE_FOLD;
    });
    int offset = musicInfoModels.length - mims.length;

    final Widget row = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // todo 2 to 1
        Provider.of<MusicInfoData>(context, listen: false)
            .setMusicInfoList(mims);
        Provider.of<MusicInfoData>(context, listen: false)
            .setPlayIndex(index - offset);

        eventBus.fire(MusicPlayerEventBus(MusicPlayerEvent.play));
      },
      child: Container(
        color: playId == musicInfoModels[index].id &&
                audioPlayerState == AudioPlayerState.PLAYING
            ? themeData.accentColor
            : themeData.backgroundColor,
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
                            const Padding(padding: EdgeInsets.only(right: 5.0)),
                            Expanded(
                              child: Text(
                                musicInfoModels[index].name,
                                maxLines: 1,
                                style: themeData.textTheme.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.only(top: 8.0)),
                        Text(
                          musicInfoModels[index].fullpath,
                          style: themeData.textTheme.subtitle,
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
                    Navigator.of(context).push(CupertinoPageRoute<void>(
                      title: "hehe",
                      builder: (BuildContext context) => MyHttpServer(
                          // color: color,
                          // colorName: colorName,
                          // index: index,
                          ),
                    ));
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
}
