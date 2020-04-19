import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/components/FileRowItem.dart';
import 'package:provider/provider.dart';

import '../models/MusicInfoModel.dart';
import '../services/Database.dart';

class FileList2Screen extends StatefulWidget {
  FileList2Screen({Key key, this.musicInfoModel}) : super(key: key);

  static const String routeName = '/filelist2';

  MusicInfoModel musicInfoModel;

  @override
  _FileList2Screen createState() => _FileList2Screen();
}

class _FileList2Screen extends State<FileList2Screen>
    with SingleTickerProviderStateMixin {
  List<MusicInfoModel> _musicInfoModels = [];
  Animation<double> animation;

  bool _isLoding = false;

  @override
  void initState() {
    super.initState();
    _refreshList(widget.musicInfoModel.fullpath);
  }

  //销毁
  @override
  void dispose() {
    super.dispose();
  }

  _refreshList(String path) async {
    DBProvider.db.getMusicInfoByPath(path).then((onValue) {
      setState(() {
        _musicInfoModels = onValue;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return CupertinoPageScaffold(
        backgroundColor: themeData.backgroundColor,
        child: RefreshIndicator(
          color: Colors.white,
          backgroundColor: themeData.primaryColor,
          child: CustomScrollView(
            semanticChildCount: _musicInfoModels.length,
            slivers: <Widget>[
              CupertinoSliverNavigationBar(
                largeTitle: Text(
                  widget.musicInfoModel.name,
                  style: themeData.primaryTextTheme.headline,
                ),
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
                        return FileRowItem(
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
            return _refreshList(widget.musicInfoModel.fullpath).then((value) {
              print('success');
              setState(() {
                _isLoding = false;
              });
            }).catchError((error) {
              print('failed');
            });
          },
        ));
  }
}
