import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/common/Global.dart';
import 'package:hello_world/components/rowitem/WebDavFileRowItem.dart';
import 'package:hello_world/models/CloudServiceModel.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/services/AdmobService.dart';
import 'package:hello_world/services/CloudService.dart';
import 'package:hello_world/services/Database.dart';
import 'package:hello_world/utils/ToastUtils.dart';
import 'package:hello_world/utils/webdav/file.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

class NextCloudFileScreen extends StatefulWidget {
  NextCloudFileScreen({
    Key key,
    this.cloudServiceModel,
    this.path,
    this.level,
    this.filePath,
    this.title,
  }) : super(key: key);

  static const String className = "NextCloudFileScreen";

  static const String routeName = '/filelist2';

  String path = "/";
  String title = "";
  String filePath = "";
  int level = 0;

  CloudServiceModel cloudServiceModel;

  @override
  _NextCloudFileScreen createState() => _NextCloudFileScreen();
}

class _NextCloudFileScreen extends State<NextCloudFileScreen>
    with SingleTickerProviderStateMixin {
  List<WebDavFile> _files = [];
  Animation<double> animation;
  List<String> _downloadedFiles;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshList(widget.path);

    if (widget.cloudServiceModel != null) {
      CloudService.cs.initWebDavClient(widget.cloudServiceModel);
    }
  }

  //销毁
  @override
  void dispose() {
    super.dispose();
  }

  _refreshList(String path) async {
    if (_isLoading) return null;
    setState(() {
      _isLoading = true;
    });
    List<String> downloadedFiles = [];

    try {
      List<MusicInfoModel> nextCloudPath =
          await DBProvider.db.getMusicInfoByPath(widget.filePath.toLowerCase());
      if (nextCloudPath.length >= 1) {
        nextCloudPath.forEach((f) {
          downloadedFiles.add(f.sourcepath);
        });
      }
    } catch (error) {
      print(error);
    }

    CloudService.cs.list(path).then((files) {
      setState(() {
        _isLoading = false;
        _files = files;
        _downloadedFiles = downloadedFiles;
      });
    }).catchError((error) {
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return CupertinoPageScaffold(
        backgroundColor: themeData.backgroundColor,
        navigationBar: CupertinoNavigationBar(
          border: null,
          backgroundColor: themeData.backgroundColor,
          middle: Text(
            widget.title,
            style: themeData.primaryTextTheme.title,
          ),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              _actionSheet(context);
            },
            child: Icon(
              Icons.more_vert,
              color: themeData.primaryColor,
            ),
          ),
        ),
        child: _isLoading
            ? new Container(
                child: new Center(
                  child: new CupertinoActivityIndicator(
                    radius: 15,
                  ),
                ),
              )
            : RefreshIndicator(
                color: Colors.white,
          backgroundColor: themeData.primaryColorLight,
                child: CustomScrollView(
                  semanticChildCount: _files.length,
                  slivers: <Widget>[
                    SliverPadding(
                      padding: const EdgeInsets.only(
                          top: 0.0, left: 0.0, right: 0.0, bottom: 20.0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Global.showAd
                              ? Container(
                                  child: AdmobBanner(
                                    adUnitId: AdMobService.getBannerAdUnitId(
                                        NextCloudFileScreen.className),
                                    adSize: AdmobBannerSize.FULL_BANNER,
                                    listener: (AdmobAdEvent event,
                                        Map<String, dynamic> args) {
                                      AdMobService.handleEvent(
                                          event, args, 'Banner');
                                    },
                                  ),
                                )
                              : Container(),
                        ]),
                      ),
                    ),
                    Consumer<MusicInfoData>(
                      builder: (context, musicInfoData, _) => SliverPadding(
                        // Top media padding consumed by CupertinoSliverNavigationBar.
                        // Left/Right media padding consumed by Tab1RowItem.
                        padding: EdgeInsets.only(
                            left: 0, top: 0, right: 0, bottom: 70),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return WebDavFileRowItem(
                                level: widget.level,
                                lastItem: index == _files.length - 1,
                                index: index,
                                file: _files[index],
                                filePath: widget.filePath,
                                downloadedFiles: _downloadedFiles,
                                cloudServiceModel: widget.cloudServiceModel,
//                          playId: musicInfoData.musicInfoModel.id,
//                          audioPlayerState: musicInfoData.audioPlayerState,
//                          musicInfoFavIDSet: musicInfoData.musicInfoFavIDSet,
                              );
                            },
                            childCount: _files.length,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                onRefresh: () => _refreshList(widget.path),
              ));
  }

  _actionSheet(BuildContext context1) {
    ThemeData themeData = Theme.of(context1);
    showCupertinoModalBottomSheet(
      expand: false,
      useRootNavigator: true,
      bounce: true,
      elevation: 10,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context, scrollController) => Material(
        color: Color(0xffececec),
        child: SafeArea(
          top: false,
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            ListTile(
              title: Text(widget.title),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(
                  CupertinoIcons.clear_circled_solid,
                  color: Colors.grey,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            new Divider(color: Colors.grey),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                ),
                padding: EdgeInsets.only(left: 15),
                child: GestureDetector(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text("退出账号"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.exit_to_app,
                          color: Colors.black45,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    var updateValue = {
                      "password": "",
                      "signedin": false,
                      "updatetime": 0,
                    };

                    Navigator.of(context).pop();

                    CloudService.cs
                        .updateCloudService(
                            widget.cloudServiceModel.id, updateValue)
                        .then((res) {
                      if (res > 0) {

                        for (int i = 0; i <= widget.level; i++) {
                          Navigator.of(context1).pop();
                        }

                        ToastUtils.show("已成功退出");
                      }
                    });
                  },
                ),
              ),
            ),
            new Divider(),
            Padding(
              padding: EdgeInsets.only(bottom: 170),
            ),
          ]),
        ),
      ),
    );
  }
}
