//import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/components/FileRowItem.dart';
import 'package:hello_world/screens/CloudServiceScreen.dart';
import 'package:provider/provider.dart';

import '../models/MusicInfoModel.dart';
import '../services/Database.dart';

class FileListScreen extends StatefulWidget {
  @override
  _FileListScreen createState() => _FileListScreen();
  static const String routeName = '/filelist';
}

class _FileListScreen extends State<FileListScreen>
    with SingleTickerProviderStateMixin {
  List<MusicInfoModel> _musicInfoModels = [];
  String path = "/";
  int currentControl = 0;

  bool _isLoding = false;

  @override
  void initState() {
    super.initState();

    _refreshList(path);


//    MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
//      keywords: <String>['flutterio', 'beautiful apps'],
//      contentUrl: 'https://flutter.io',
//      birthday: DateTime.now(),
//      childDirected: false,
//      designedForFamilies: false,
//      gender: MobileAdGender.male, // or MobileAdGender.female, MobileAdGender.unknown
//      testDevices: <String>[], // Android emulators are considered test devices
//    );
//
//    BannerAd myBanner = BannerAd(
//      // Replace the testAdUnitId with an ad unit id from the AdMob dash.
//      // https://developers.google.com/admob/android/test-ads
//      // https://developers.google.com/admob/ios/test-ads
//      adUnitId: BannerAd.testAdUnitId,
//      size: AdSize.smartBanner,
//      targetingInfo: targetingInfo,
//      listener: (MobileAdEvent event) {
//        print("BannerAd event is $event");
//      },
//    );
//
//
//    myBanner
//    // typically this happens well before the ad is shown
//      ..load()
//      ..show(
//        // Positions the banner ad 60 pixels from the bottom of the screen
//        anchorOffset: 60.0,
//        // Positions the banner ad 10 pixels from the center of the screen to the right
//        horizontalCenterOffset: 10.0,
//        // Banner Position
//        anchorType: AnchorType.bottom,
//      );
//
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

    return CupertinoPageScaffold(
        backgroundColor: themeData.backgroundColor,
        navigationBar: CupertinoNavigationBar(
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
                  height: _windowHeight - 160,
                  width: _windowWidth,
                  child: CupertinoScrollbar(
                    child: CustomScrollView(
                        semanticChildCount: _musicInfoModels.length,
                        slivers: <Widget>[
                          SliverList(
                            delegate: SliverChildListDelegate([
                              currentControl == 0
                                  ? Container(
                                      height: _windowHeight -
                                          _bottomBarHeight -
                                          50 -
                                          150,
                                      child: Consumer<MusicInfoData>(
                                        builder: (context, musicInfoData, _) =>
                                            Container(
                                          width: _windowWidth,
                                          height: _windowHeight,
                                          child: CustomScrollView(
                                            semanticChildCount: 3,
                                            slivers: <Widget>[
                                              SliverPadding(
                                                padding: EdgeInsets.only(
                                                    left: 0,
                                                    top: 0,
                                                    right: 0,
                                                    bottom: 20),
                                                sliver: SliverList(
                                                  delegate:
                                                      SliverChildBuilderDelegate(
                                                    (BuildContext context,
                                                        int index) {
                                                      return FileRowItem(
                                                        index: index,
                                                        musicInfoModels:
                                                            _musicInfoModels,
                                                        audioPlayerState:
                                                            musicInfoData
                                                                .audioPlayerState,
                                                        musicInfoFavIDSet:
                                                            musicInfoData
                                                                .musicInfoFavIDSet,
                                                        playId: musicInfoData
                                                            .musicInfoModel.id,
                                                      );
                                                    },
                                                    childCount:
                                                        _musicInfoModels.length,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ))
                                  : Container(
                                      height: _windowHeight -
                                          _bottomBarHeight -
                                          50 -
                                          150,
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
