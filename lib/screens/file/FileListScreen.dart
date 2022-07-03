//import 'package:firebase_admob/firebase_admob.dart';
// import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/common/Global.dart';
import 'package:hello_world/components/rowitem/FileRowItem.dart';
import 'package:hello_world/services/FileManager.dart';

// import 'package:hello_world/services/AdmobService.dart3';
import 'package:provider/provider.dart';

import '../../models/MusicInfoModel.dart';
import '../../services/Database.dart';

// 文件管理首屏
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

  bool _isLoding = false;

  // AdmobBannerSize bannerSize;
  // AdmobInterstitial interstitialAd;
  // AdmobReward rewardAd;

  @override
  void initState() {
    super.initState();

    _refreshList(path);
    // bannerSize = AdmobBannerSize.FULL_BANNER;
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
          backgroundColor: themeData.primaryColor,
          child: CupertinoScrollbar(
            child: CustomScrollView(
                semanticChildCount: _musicInfoModels.length,
                slivers: <Widget>[
                  CupertinoSliverNavigationBar(
                    //actionsForegroundColor: themeData.primaryColorDark,
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
                    trailing: CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Icon(
                        Icons.more_vert,
                        color: themeData.primaryColor,
                      ),
                      onPressed: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context1) {
                            return _actionSheet(context1, context);
                          },
                        );
                      },
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 8.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Global.showAd
                              ? Container(
                                  // child:
                                  // AdmobBanner( adUnitId: AdMobService.getBannerAdUnitId(
                                  //       FileListScreen.className),
                                  //   adSize: bannerSize,
                                  //   listener: (AdmobAdEvent event,
                                  //       Map<String, dynamic> args) {
                                  //     AdMobService.handleEvent(
                                  //         event, args, 'Banner');
                                  //   },
                                  // ),
                                  )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                  Consumer<MusicInfoData>(
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
                              lastItem: index == _musicInfoModels.length - 1,
                              index: index,
                              mplID: 0,
                              musicInfoModels: _musicInfoModels,
                              audioPlayerState: musicInfoData.audioPlayerState,
                              musicInfoFavIDSet:
                                  musicInfoData.musicInfoFavIDSet,
                              playId: musicInfoData.musicInfoModel.id,
                            );
                          },
                          childCount: _musicInfoModels.length,
                        ),
                      ),
                    ),
                  ),
                ]),
          ),
          onRefresh: () async {
            if (!_isLoding) {
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
            }
          },
        ));
  }

  // 底部弹出菜单actionSheet
  Widget _actionSheet(BuildContext context1, BuildContext context) {
    ThemeData themeData = Theme.of(context);
    var windowHeight = MediaQuery.of(context).size.height;

    return new CupertinoActionSheet(
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text(
            '清理缓存',
          ),
          onPressed: () {
            Navigator.of(context1).pop();

            FileManager.cleanAllFiles();

            // _addPlayList();
          },
        ),
//        CupertinoActionSheetAction(
//          child: Text(
//            '新建场景',
//          ),
//          onPressed: () {
//            Navigator.pop(context1);
//
//            _addSceen();
//          },
//        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(
          '取消',
        ),
        onPressed: () {
          Navigator.of(context1).pop();
        },
      ),
    );
  }
}
