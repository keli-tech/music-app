import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/common/Global.dart';
import 'package:hello_world/components/rowitem/FileRowItem.dart';
import 'package:hello_world/screens/file/FileListScreen.dart';
import 'package:hello_world/services/AdmobService.dart';
import 'package:provider/provider.dart';

import '../../models/MusicInfoModel.dart';
import '../../services/Database.dart';

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
        navigationBar: CupertinoNavigationBar(
          border: null,
          middle: Text(
            widget.musicInfoModel.name,
            style: themeData.primaryTextTheme.title,
          ),
          backgroundColor: themeData.backgroundColor,
        ),
        child: RefreshIndicator(
          color: Colors.white,
          backgroundColor: themeData.primaryColorLight,
          child: CustomScrollView(
            semanticChildCount: _musicInfoModels.length,
            slivers: <Widget>[

              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    vertical: 5.0, horizontal: 8.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Global.showAd
                          ? Container(
                        child: AdmobBanner(
                          adUnitId: AdMobService.getBannerAdUnitId(
                              FileListScreen.className),
                          adSize: AdmobBannerSize.FULL_BANNER,
                          listener: (AdmobAdEvent event,
                              Map<String, dynamic> args) {
                            AdMobService.handleEvent(
                                event, args, 'Banner');
                          },
                        ),
                      )
                          : Container(),
                    ],
                  ),
                ),
              ),

              Consumer<MusicInfoData>(
                builder: (context, musicInfoData, _) => SliverPadding(
                  // Top media padding consumed by CupertinoSliverNavigationBar.
                  // Left/Right media padding consumed by Tab1RowItem.
                  padding:
                      EdgeInsets.only(left: 15, top: 10, right: 15, bottom: 70),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return FileRowItem(
                          lastItem: index == _musicInfoModels.length - 1,
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
              setState(() {
                _isLoding = false;
              });
            }).catchError((error) {
              print(error);
            });
          },
        ));
  }
}
