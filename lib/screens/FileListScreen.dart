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
  Set<int> _musicInfoFavIDSet = Set();
  String path = "/";

  bool _isLoding = false;

  @override
  void initState() {
    super.initState();

    _refreshList(path);
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
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
                backgroundColor: themeData.backgroundColor,
              ),
              SliverPadding(
                padding: const EdgeInsets.all(8.0),
                sliver: new SliverGrid(
                  //Grid
                  gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, //Grid按两列显示
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 10.0,
                    childAspectRatio: 3.0,
                  ),
                  delegate: new SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      //创建子widget
                      return _buttonFunction(index, context);
                    },
                    childCount: 3,
                  ),
                ),
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
                          audioPlayerState: musicInfoData.audioPlayerState,
                          musicInfoFavIDSet: musicInfoData.musicInfoFavIDSet,
                          playId: musicInfoData.musicInfoModel.id,
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

_buttonFunction(int index, BuildContext context) {
  switch (index) {
    case 0:
      return new Center(
          child: FlatButton(
              onPressed: () {
                print(111);
              },
              padding: const EdgeInsets.only(
                  left: 16.0, top: 8.0, bottom: 8.0, right: 8.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.search,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: 10),
                  new Text(
                    "搜索",
                    style: Theme.of(context).textTheme.button,
                  ),
                ],
              )));
      break;
    case 1:
      return new Center(
        child: Container(),
      );
      break;
    case 2:
      return new Center(
          child: CupertinoButton(
              pressedOpacity: 0.8,
              onPressed: () {
                showModalBottomSheet<void>(
                    context: context,
                    useRootNavigator: true,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return CloudServiceScreen(
                        statusBarHeight:
                            MediaQuery.of(context).padding.top.toInt(),
                      );
                    });
                return;
              },
              padding: const EdgeInsets.only(
                  left: 16.0, top: 8.0, bottom: 8.0, right: 8.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.cloud_download,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: 10),
                  new Text(
                    "云同步",
                    style: Theme.of(context).textTheme.button,
                  ),
                ],
              )));
      break;
    default:
      return null;
      break;
  }
}
