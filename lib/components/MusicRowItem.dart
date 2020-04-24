import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/screens/MyHttpServer.dart';
import 'package:hello_world/services/EventBus.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:provider/provider.dart';

class MusicRowItem extends StatelessWidget {
  const MusicRowItem({
    this.index,
    this.musicInfoModels,
    this.playId,
    this.audioPlayerState,
    this.musicInfoFavIDSet,
  });

  final int index;
  final List<MusicInfoModel> musicInfoModels;
  final int playId;
  final AudioPlayerState audioPlayerState;
  final Set<int> musicInfoFavIDSet;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    MusicInfoModel _musicInfoModel = musicInfoModels[index];
    List<MusicInfoModel> mims =
        musicInfoModels.getRange(0, musicInfoModels.length).toList();
    mims.removeWhere((music) {
      return music.type == MusicInfoModel.TYPE_FOLD;
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
                            const Padding(padding: EdgeInsets.only(right: 5.0)),
                            Expanded(
                              child: Text(
                                _musicInfoModel.type != MusicInfoModel.TYPE_FOLD
                                    ? '${_musicInfoModel.title} - ${_musicInfoModel.artist}'
                                    : "",
                                maxLines: 1,
                                style: themeData.textTheme.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.only(top: 8.0)),
                        Text(
                          _musicInfoModel.type !=  MusicInfoModel.TYPE_FOLD
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
