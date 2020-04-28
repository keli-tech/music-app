import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/models/MusicPlayListModel.dart';
import 'package:hello_world/screens/album/PlayListDetailScreen.dart';
import 'package:hello_world/services/Database.dart';
import 'package:hello_world/services/MusicControlService.dart';

const List<Color> coolColors = <Color>[
  Color.fromARGB(255, 255, 149, 0),
  Color.fromARGB(255, 255, 204, 0),
  Color.fromARGB(255, 255, 59, 48),
  Color.fromARGB(255, 76, 217, 100),
  Color.fromARGB(255, 90, 200, 250),
  Color.fromARGB(255, 0, 122, 255),
  Color.fromARGB(255, 88, 86, 214),
  Color.fromARGB(255, 255, 45, 85),
];

Color getColor(int index) {
  return coolColors[index % coolColors.length];
}

class ChipScreenComp extends StatefulWidget {
  ChipScreenComp(
      {Key key,
      this.title,
      this.index,
      this.musicPlayListModel,
      this.refreshFunc})
      : super(key: key);

  final String title;
  int index;

  Function() refreshFunc;

  MusicPlayListModel musicPlayListModel;

  @override
  _ChipScreenCompState createState() => _ChipScreenCompState();
}

class _ChipScreenCompState extends State<ChipScreenComp>
    with SingleTickerProviderStateMixin {
  var deleteFunction = null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Chip(
        deleteButtonTooltipMessage: "",
        onDeleted: deleteFunction,
        deleteIcon: Icon(
          CupertinoIcons.clear_circled_solid,
        ),
        padding: EdgeInsets.only(left: 5.0, right: 0, top: 5.0, bottom: 5.0),
        avatar: new CircleAvatar(
            backgroundColor: Colors.white70,
            child: Icon(
              Icons.play_circle_outline,
              color: getColor(widget.index),
            )),
        label: new Text(
          widget.musicPlayListModel.name,
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      onDoubleTap: () {
        Navigator.of(context).push(CupertinoPageRoute<void>(
          title: widget.musicPlayListModel.name,
          builder: (BuildContext context) => PlayListDetailScreen(
            musicPlayListModel: widget.musicPlayListModel,
            statusBarHeight: MediaQuery.of(context).padding.top,
          ),
        ));
      },
      onLongPress: () {
        var _deleteFunction = () {
          showCupertinoDialog<String>(
            context: context,
            builder: (BuildContext context1) => CupertinoAlertDialog(
              title: const Text('确定删除？'),
              content: Text(widget.musicPlayListModel.name),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(
                    '取消',
                  ),
                  isDefaultAction: true,
                  onPressed: () {
                    setState(() {
                      deleteFunction = null;
                    });
                    Navigator.pop(context1, 'Cancel');
                  },
                ),
                CupertinoDialogAction(
                  child: Text(
                    '删除',
                  ),
                  isDestructiveAction: true,
                  isDefaultAction: true,
                  onPressed: () {
                    setState(() {
                      deleteFunction = null;
                    });

                    DBProvider.db
                        .deleteMusicPlayList(widget.musicPlayListModel.id)
                        .then((onValue) {
                      Fluttertoast.showToast(
                          msg: "已删除歌单",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black45,
                          textColor: Colors.white,
                          fontSize: 13.0);

                      widget.refreshFunc();
                    });

                    Navigator.pop(context1, 'Cancel');
                  },
                ),
              ],
            ),
          );
        };
        setState(() {
          deleteFunction = deleteFunction != null ? null : _deleteFunction;
        });
      },
      onTap: () async {
        List<MusicInfoModel> musicInfoModels = await DBProvider.db
            .getMusicInfoByPlayListId(widget.musicPlayListModel.id);
        if (musicInfoModels.length > 0) {
          MusicControlService.play(context, musicInfoModels, 0);
        }
      },
    );
  }
}
