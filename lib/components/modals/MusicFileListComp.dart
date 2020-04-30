import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:hello_world/components/rowitem/MusicColorReverseRowItem.dart';
import 'package:hello_world/components/rowitem/MusicRowItem.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

// 我喜欢的音乐
// 播放列表
// 专辑
class MusicFileListComp extends StatefulWidget {
  MusicFileListComp({Key key, this.statusBarHeight, this.colorReverse})
      : super(key: key);
  static const String routeName = '/playlist/detail';

  @override
  _MusicFileListComp createState() => _MusicFileListComp();

  double statusBarHeight;
  bool colorReverse;
}

class _MusicFileListComp extends State<MusicFileListComp> {
  Logger _logger = new Logger("MusicFileListComp");

  @override
  void initState() {
    super.initState();
  }

//  @override
//  void deactivate() {
//    super.deactivate();
//    __logger.info("deactivate");
//    _refreshList();
//  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    double _windowHeight = MediaQuery.of(context).size.height;

    ThemeData themeData = Theme.of(context);
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text("当前播放列表"),
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
          Flexible(
            child: Container(
              child: Consumer<MusicInfoData>(
                builder: (context, musicInfoData, _) => ListView.builder(
                    padding: EdgeInsets.only(
                      left: 15,
                      right: 15,
                    ),
                    shrinkWrap: true,
                    itemCount: musicInfoData.musicInfoList.length,
                    itemBuilder: (context, index) {
                      if (widget.colorReverse != null && widget.colorReverse) {
                        return MusicColorReverseRowItem(
                          statusBarHeight: widget.statusBarHeight,
                          lastItem:
                              index == musicInfoData.musicInfoList.length - 1,
                          index: index,
                          musicInfoModels: musicInfoData.musicInfoList,
                          playId: musicInfoData.musicInfoModel.id,
                          audioPlayerState: musicInfoData.audioPlayerState,
                          musicInfoFavIDSet: musicInfoData.musicInfoFavIDSet,
                        );
                      } else {
                        return MusicRowItem(
                          statusBarHeight: widget.statusBarHeight,
                          lastItem:
                              index == musicInfoData.musicInfoList.length - 1,
                          index: index,
                          musicInfoModels: musicInfoData.musicInfoList,
                          playId: musicInfoData.musicInfoModel.id,
                          audioPlayerState: musicInfoData.audioPlayerState,
                          musicInfoFavIDSet: musicInfoData.musicInfoFavIDSet,
                        );
                      }
                    }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
