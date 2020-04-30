import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/components/Tile.dart';
import 'package:hello_world/models/MusicPlayListModel.dart';
import 'package:hello_world/screens/album/PlayListDetailScreen.dart';
import 'package:hello_world/services/Database.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:hello_world/services/MusicControlService.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PlayListRowItem extends StatelessWidget {
  const PlayListRowItem({
    this.index,
    this.lastItem,
    this.musicPlayListModel,
  });

  final int index;
  final bool lastItem;
  final MusicPlayListModel musicPlayListModel;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    final Widget row = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context, rootNavigator: true)
            .push(MaterialWithModalsPageRoute<void>(
          builder: (BuildContext context) => PlayListDetailScreen(
            musicPlayListModel: musicPlayListModel,
            statusBarHeight: MediaQuery.of(context).padding.top,
          ),
        ));
      },
      child: Tile(
        selected: false,
//        selected: playId == musicInfoModels[index].id &&
//            audioPlayerState == AudioPlayerState.PLAYING,
        radiusnum: 15.0,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Row(
            children: <Widget>[
//          Hero(
              Container(
//                tag: 'PlayListScreen' + musicPlayListModel.id.toString(),
                child: Container(
                  height: 76.0,
                  width: 114.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      fit: BoxFit.cover, //这个地方很重要，需要设置才能充满
                      image: FileManager.musicAlbumPictureImage(
                          musicPlayListModel.artist,
                          musicPlayListModel.imgpath),
                    ),
                  ),
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
                              musicPlayListModel.name,
                              maxLines: 1,
                              style: themeData.primaryTextTheme.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Padding(padding: EdgeInsets.only(top: 8.0)),
                      Text(
                        musicPlayListModel.musiccount.toString() + "首",
                        style: themeData.primaryTextTheme.subtitle,
                      ),
                    ],
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Tile(
                  selected: false,
                  radiusnum: 20,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: themeData.primaryColorDark,
                    foregroundColor: themeData.primaryColorLight,
                    child: Icon(
                      Icons.play_arrow,
                      color: themeData.primaryColorLight,
                      size: 18,
                    ),
                  ),
                ),
                onPressed: () async {
                  var _musicInfoModels = await DBProvider.db
                      .getMusicInfoByPlayListId(musicPlayListModel.id);

                  MusicControlService.play(context, _musicInfoModels, 0);
                },
              ),
            ],
          ),
        ),
      ),
    );

    return row;
    if (lastItem) {
    }

    return Column(
      children: <Widget>[
        const Divider(
          thickness: 0.5,
          endIndent: 5,
          indent: 5,
          height: 0.40,
        ),
        row,
      ],
    );
  }
}
