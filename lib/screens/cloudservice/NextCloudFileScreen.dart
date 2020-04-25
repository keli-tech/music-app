import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/components/rowitem/WebDavFileRowItem.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/services/CloudService.dart';
import 'package:hello_world/services/Database.dart';
import 'package:nextcloud/nextcloud.dart';
import 'package:provider/provider.dart';

class NextCloudFileScreen extends StatefulWidget {
  NextCloudFileScreen({Key key, this.musicInfoModel, this.path, this.title})
      : super(key: key);

  static const String routeName = '/filelist2';

  String path = "/";
  String title = "";

  MusicInfoModel musicInfoModel;

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
    List<MusicInfoModel> nextCloudPath =
        await DBProvider.db.getMusicInfoByPath("/nextcloud/");
    nextCloudPath.forEach((f) {
      downloadedFiles.add(f.sourcepath);
    });

    CloudService.nextCloudClientc.list(path).then((files) {
      setState(() {
        _isLoading = false;
        _files = files;
        _downloadedFiles = downloadedFiles;
      });
    }).catchError((error) {
      print('failed');
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return CupertinoPageScaffold(
        backgroundColor: themeData.backgroundColor,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: themeData.backgroundColor,
          middle: Text(
            widget.title,
            style: themeData.primaryTextTheme.title,
          ),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context1) {
                  return actionSheet(context1, context);
                },
              );
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
                backgroundColor: themeData.primaryColor,
                child: CustomScrollView(
                  semanticChildCount: _files.length,
                  slivers: <Widget>[
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
                                lastItem: index == _files.length - 1,
                                index: index,
                                file: _files[index],
                                downloadedFiles: _downloadedFiles,
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

  // 底部弹出菜单actionSheet
  Widget actionSheet(BuildContext context1, BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return new CupertinoActionSheet(
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text(
            '下载文件夹内音乐文件',
          ),
          onPressed: () {
            Navigator.of(context1).pop();

            // download
          },
        ),
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
