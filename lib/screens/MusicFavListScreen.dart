import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/components/MusicRowItem.dart';
import 'package:provider/provider.dart';

import '../models/MusicInfoModel.dart';
import '../services/Database.dart';

class MusicFavListScreen extends StatefulWidget {
  @override
  _MusicFavListScreen createState() => _MusicFavListScreen();
}

class _MusicFavListScreen extends State<MusicFavListScreen>
    with SingleTickerProviderStateMixin {
  List<MusicInfoModel> _musicInfoModels = [];
  Animation<double> animation;
  AnimationController controller;

  bool _isLoding = false;

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

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);

    _refreshList();
  }

  _refreshList() async {
    DBProvider.db.getFavMusicInfoList().then((onValue) {
      // 红心 ID Set
      Set<int> musicInfoFavIDSet = onValue.map((f) {
        return f.id;
      }).toSet();
      Provider.of<MusicInfoData>(context, listen: false)
          .setMusicInfoFavIDSet(musicInfoFavIDSet);

      setState(() {
        _musicInfoModels = onValue;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    var musicInfoData = Provider.of<MusicInfoData>(context, listen: false);

    return Container(
      color: themeData.backgroundColor,
      child: CupertinoPageScaffold(
        backgroundColor: themeData.backgroundColor,
        child: RefreshIndicator(
          color: Colors.white,
          backgroundColor: themeData.primaryColor,
          child: CustomScrollView(
            semanticChildCount: _musicInfoModels.length,
            slivers: <Widget>[
              CupertinoSliverNavigationBar(
                backgroundColor: themeData.backgroundColor,
              ),
              Consumer<MusicInfoData>(
                builder: (context, musicInfoData, _) => SliverPadding(
                  // Top media padding consumed by CupertinoSliverNavigationBar.
                  // Left/Right media padding consumed by Tab1RowItem.
                  padding:
                      EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 70),
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
          onRefresh: () {
            if (_isLoding) return null;
            setState(() {
              _isLoding = true;
            });
            return _refreshList().then((value) {
              print('success');
              setState(() {
                _isLoding = false;
              });
            }).catchError((error) {
              print('failed');
            });
          },
        ),
      ),
    );
  }
}
