import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/components/rowitem/FileRowItem.dart';
import 'package:provider/provider.dart';

import '../../models/MusicInfoModel.dart';
import '../../services/Database.dart';

class FileList2Screen extends StatefulWidget {
  FileList2Screen({Key? key, required this.fullpath, required name})
      : super(key: key);

  static const String routeName = '/filelist2';

  String fullpath = "/";
  String name = "";

  @override
  _FileList2Screen createState() => _FileList2Screen();
}

class _FileList2Screen extends State<FileList2Screen>
    with SingleTickerProviderStateMixin {
  List<MusicInfoModel> _musicInfoModels = [];

  bool _isLoding = false;

  @override
  void initState() {
    super.initState();
    _refreshList(widget.fullpath);
  }

  @override
  void deactivate() {
    super.deactivate();
    _refreshList(widget.fullpath);
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
        navigationBar: CupertinoNavigationBar(
          border: null,
          middle: Text(
            widget.name,
            style: themeData.primaryTextTheme.headline6,
          ),
          backgroundColor: themeData.backgroundColor,
        ),
        child: RefreshIndicator(
          color: Colors.white,
          backgroundColor: themeData.primaryColor,
          child: CustomScrollView(
            semanticChildCount: _musicInfoModels.length,
            slivers: <Widget>[
              Consumer<MusicInfoData>(
                builder: (context, musicInfoData, _) => SliverPadding(
                  // Top media padding consumed by CupertinoSliverNavigationBar.
                  // Left/Right media padding consumed by Tab1RowItem.
                  padding:
                      EdgeInsets.only(left: 15, top: 10, right: 15, bottom: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return FileRowItem(
                          lastItem: index == _musicInfoModels.length - 1,
                          index: index,
                          musicInfoModels: _musicInfoModels,
                          mplID: 0,
                          statusBarHeight: 0,
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
          onRefresh: () async {
            if (!_isLoding) {
              setState(() {
                _isLoding = true;
              });
              return _refreshList(widget.fullpath).then((value) {
                setState(() {
                  _isLoding = false;
                });
              }).catchError((error) {
                print(error);
              });
            }
          },
        ));
  }
}
