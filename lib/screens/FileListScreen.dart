//import 'package:firebase_admob/firebase_admob.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/components/rowitem/FileRowItem.dart';
import 'package:hello_world/screens/CloudServiceScreen.dart';
import 'package:hello_world/services/AdmobService.dart';
import 'package:provider/provider.dart';

import '../models/MusicInfoModel.dart';
import '../services/Database.dart';

class FileListScreen extends StatefulWidget {
  @override
  _FileListScreen createState() => _FileListScreen();
  static const String routeName = '/filelist';

  static const String className = 'FileListScreen';
}

class _FileListScreen extends State<FileListScreen>
    with SingleTickerProviderStateMixin {
  List<MusicInfoModel> _musicInfoModels = [];
  String path = "/";
  int currentControl = 0;

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
    var _windowHeight = MediaQuery.of(context).size.height;
    var _bottomBarHeight = MediaQuery.of(context).padding.bottom;
    var _windowWidth = MediaQuery.of(context).size.width;

    double _statusBarHeight = MediaQuery.of(context).padding.top;

    return CupertinoPageScaffold(
        backgroundColor: themeData.backgroundColor,
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            "文件",
            style: themeData.primaryTextTheme.title,
          ),
          backgroundColor: themeData.backgroundColor,
        ),
        child: RefreshIndicator(
          color: Colors.white,
          backgroundColor: themeData.primaryColor,
          child: Container(
            height: _windowHeight,
            width: _windowWidth,
            child: Column(
              children: <Widget>[
                Container(
                  child: AdmobBanner(
                    adUnitId: AdMobService.getBannerAdUnitId(
                        FileListScreen.className),
                    adSize: bannerSize,
                    listener: (AdmobAdEvent event, Map<String, dynamic> args) {
                      AdMobService.handleEvent(event, args, 'Banner');
                    },
                  ),
                ),
                Container(
                  width: _windowWidth,
                  child: CupertinoSlidingSegmentedControl(
                    padding: EdgeInsets.all(4.0),
                    groupValue: currentControl,
                    onValueChanged: (int newValue) {
                      setState(() {
                        currentControl = newValue;
                      });
                    },
                    children: {
                      0: Container(
                        alignment: Alignment.center,
                        height: 35,
                        child: Text("文件"),
                      ),
                      1: Container(
                        alignment: Alignment.center,
                        height: 35,
                        child: Text("云同步"),
                      ),
                    },
                  ),
                ),
                Container(
                  height: _windowHeight -
                      160 -
                      50 -
                      _bottomBarHeight -
                      bannerSize.height,
                  width: _windowWidth,
                  child: CupertinoScrollbar(
                    child: CustomScrollView(
                        semanticChildCount: _musicInfoModels.length,
                        slivers: <Widget>[
                          currentControl == 0
                              ? Consumer<MusicInfoData>(
                                  builder: (context, musicInfoData, _) =>
                                      SliverPadding(
                                    padding: EdgeInsets.only(
                                        left: 0, top: 0, right: 0, bottom: 20),
                                    sliver: SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (BuildContext context, int index) {
                                          return FileRowItem(
                                            statusBarHeight: _statusBarHeight,
                                            lastItem: index ==
                                                _musicInfoModels.length - 1,
                                            index: index,
                                            musicInfoModels: _musicInfoModels,
                                            audioPlayerState:
                                                musicInfoData.audioPlayerState,
                                            musicInfoFavIDSet:
                                                musicInfoData.musicInfoFavIDSet,
                                            playId:
                                                musicInfoData.musicInfoModel.id,
                                          );
                                        },
                                        childCount: _musicInfoModels.length,
                                      ),
                                    ),
                                  ),
                                )
                              : SliverList(
                                  delegate: SliverChildListDelegate([
                                    Container(
                                        height: _windowHeight -
                                            160 -
                                            50 -
                                            _bottomBarHeight -
                                            bannerSize.height,
                                        child: CloudServiceScreen())
                                  ]),
                                ),
                        ]),
                  ),
                )
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
