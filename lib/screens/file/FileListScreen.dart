import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/common/Global.dart';
import 'package:hello_world/components/rowitem/FileRowItem.dart';
import 'package:hello_world/services/AdmobService.dart';
import 'package:provider/provider.dart';

import '../../models/MusicInfoModel.dart';
import '../../services/Database.dart';

class FileListScreen extends StatefulWidget {
  FileListScreen({
    Key key,
  }) : super(key: key);

  @override
  _FileListScreen createState() => _FileListScreen();
  static const String routeName = '/filelist';

  static const String className = 'FileListScreen';
}

class _FileListScreen extends State<FileListScreen>
    with SingleTickerProviderStateMixin {
  List<MusicInfoModel> _musicInfoModels = [];
  String path = "/";

  bool _isLoding = false;

  AdmobBannerSize bannerSize;
  AdmobInterstitial interstitialAd;
  AdmobReward rewardAd;

  @override
  void initState() {
    super.initState();

    _refreshList(path);
    bannerSize = AdmobBannerSize.FULL_BANNER;
  }

  @override
  void deactivate() {
    super.deactivate();
    _refreshList(path);
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
    double _bottomBarHeight = MediaQuery.of(context).padding.bottom;
    double _windowHeight =
        MediaQuery.of(context).size.height - _bottomBarHeight;
    double _windowWidth = MediaQuery.of(context).size.width;
    double _statusBarHeight = MediaQuery.of(context).padding.top;

    return CupertinoPageScaffold(
        backgroundColor: themeData.backgroundColor,
        child: RefreshIndicator(
          color: Colors.white,
          backgroundColor: themeData.primaryColorLight,
          child: CupertinoScrollbar(
            child: CustomScrollView(
              semanticChildCount: _musicInfoModels.length,
              slivers: <Widget>[
                CupertinoSliverNavigationBar(
                  actionsForegroundColor: themeData.primaryColorDark,
                  backgroundColor: themeData.primaryColorLight,
                  border: null,
                  automaticallyImplyTitle: false,
                  automaticallyImplyLeading: false,
                  largeTitle: Text(
                    "文件",
                    style: TextStyle(
                      color: themeData.primaryColorDark,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 15.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Global.showAd
                            ? Container(
                                child: AdmobBanner(
                                  adUnitId: AdMobService.getBannerAdUnitId(
                                      FileListScreen.className),
                                  adSize: bannerSize,
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
                _musicInfoModels.length > 0
                    ? Consumer<MusicInfoData>(
                        builder: (context, musicInfoData, _) => SliverPadding(
                          padding: EdgeInsets.only(
                              left: 15,
                              top: 10,
                              right: 15,
                              bottom: _bottomBarHeight + 50),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                return FileRowItem(
                                  statusBarHeight: _statusBarHeight,
                                  lastItem:
                                      index == _musicInfoModels.length - 1,
                                  index: index,
                                  musicInfoModels: _musicInfoModels,
                                  audioPlayerState:
                                      musicInfoData.audioPlayerState,
                                  musicInfoFavIDSet:
                                      musicInfoData.musicInfoFavIDSet,
                                  playId: musicInfoData.musicInfoModel.id,
                                );
                              },
                              childCount: _musicInfoModels.length,
                            ),
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 15.0),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            Container(
                              child: Center(
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(height: 40),
                                    Text(
                                      "暂无音乐, 前往云同步",
                                      style:
                                          themeData.primaryTextTheme.subtitle,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
              ],
            ),
          ),
          onRefresh: () {
            if (_isLoding) return null;
            setState(() {
              _isLoding = true;
            });
            return _refreshList(path).then((value) {
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
