import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:hello_world/components/rowitem/MusicRowItem.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../../models/MusicInfoModel.dart';
import '../../services/Database.dart';

// 我喜欢的音乐
// 播放列表
// 专辑
class ArtistListDetailScreen extends StatefulWidget {
  ArtistListDetailScreen({
    Key key,
    this.statusBarHeight,
    this.artist,
  }) : super(key: key);
  static const String routeName = '/playlist/detail';

  @override
  _ArtistListDetailScreen createState() => _ArtistListDetailScreen();

  double statusBarHeight;
  String artist;
}

class _ArtistListDetailScreen extends State<ArtistListDetailScreen>
    with SingleTickerProviderStateMixin {
  List<MusicInfoModel> _musicInfoModels = [];
  Logger _logger = new Logger(ArtistListDetailScreen.routeName);

  @override
  void initState() {
    super.initState();

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
    String artist = widget.artist;
    DBProvider.db.getMusicInfoByArtist(artist).then((onValue) {
      setState(() {
        _musicInfoModels = onValue;
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
          widget.artist,
          style: themeData.primaryTextTheme.headline6,
        ),
      ),
      child: CustomScrollView(
        semanticChildCount: _musicInfoModels.length,
        slivers: <Widget>[
          Consumer<MusicInfoData>(
            builder: (context, musicInfoData, _) => SliverPadding(
              padding: EdgeInsets.only(left: 15, top: 10, right: 15, bottom: 70),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return MusicRowItem(
                      statusBarHeight: _statusBarHeight,
                      lastItem: index == _musicInfoModels.length - 1,
                      index: index,
                      mplID: 0,
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
}
