import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hello_world/models/MusicPlayListModel.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:image_picker/image_picker.dart';

import '../services/Database.dart';

class PlayListCreateComp extends StatefulWidget {
  PlayListCreateComp({Key key, this.musicPlayListModel}) : super(key: key);

  MusicPlayListModel musicPlayListModel;

  @override
  _PlayListCreateComp createState() => _PlayListCreateComp();
}

class _PlayListCreateComp extends State<PlayListCreateComp> {
  File _image;
  String _name = "";
  TextEditingController _chatTextController;

  @override
  void initState() {
    _chatTextController = TextEditingController();

    super.initState();
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Container(
        color: themeData.backgroundColor,
        padding: EdgeInsets.only(top: 20),
        child: Scaffold(
          backgroundColor: themeData.backgroundColor,
          appBar: CupertinoNavigationBar(
            padding: EdgeInsetsDirectional.only(top: 00),
            leading: FlatButton(
              child: Icon(
                Icons.keyboard_arrow_down,
                color: themeData.primaryColor,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            middle: Text(
              '新建歌单',
              style: themeData.primaryTextTheme.headline,
            ),
            backgroundColor: themeData.backgroundColor,
          ),
          body: Builder(builder: buildBody),
        ));
  }

  Widget buildBody(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 5, top: 30, right: 5, bottom: 10),
      child: Center(
        child: Column(
          children: <Widget>[
            new ListTile(
              title: CupertinoTextField(
                prefix: Text("名称："),
                controller: _chatTextController,
                suffixMode: OverlayVisibilityMode.editing,
                textCapitalization: TextCapitalization.sentences,
                clearButtonMode: OverlayVisibilityMode.editing,
                keyboardType: TextInputType.text,
                autocorrect: false,
                autofocus: true,
              ),
//
//              TextField(
//                autofocus: false,
//                style: themeData.textTheme.title,
//                cursorColor: Colors.red,
//                onChanged: (onValue) {
//                  setState(() {
//                    _name = onValue;
//                  });
//                },
//                decoration: InputDecoration(
//                  labelStyle: themeData.primaryTextTheme.title,
//                  hintText: "请输入名称",
//                  hintStyle: themeData.primaryTextTheme.subtitle,
//                ),
//              ),
            ),
            new ListTile(
              onTap: getImage,
              title: new Text(
                '请选择图片',
              ),
              leading: Text(
                "图片",
              ),
              trailing: IconButton(
                icon: Icon(Icons.clear),
                color: Colors.red,
                onPressed: () {
                  setState(() {
                    _image = null;
                  });
                },
              ),
            ),
            _image != null
                ? Image(
                    width: MediaQuery.of(context).size.width / 2,
                    image: FileImage(_image),
                  )
                : Text(""),
            SizedBox(
              height: 30,
            ),
            RaisedButton(
              disabledColor: Colors.grey,
              padding:
                  EdgeInsets.only(left: 30, top: 15, right: 30, bottom: 15),
              key: Key("save"),
              color: themeData.primaryColor,
              onPressed: _name.trim().length <= 0
                  ? null
                  : () async {
                      String name = _name.trim();

                      if (_image != null) {
                        _image.copySync(
                            FileManager.musicAlbumPictureFullPath("-", name)
                                .path);
                      }

                      MusicPlayListModel newMusicPlayListModel =
                          MusicPlayListModel(
                              name: name,
                              artist: "-",
                              type: MusicPlayListModel.TYPE_PLAY_LIST,
                              sort: 100,
                              imgpath: name);

                      DBProvider.db
                          .newMusicPlayList(newMusicPlayListModel)
                          .then((onValue) {
                        if (onValue > 0) {
                          Fluttertoast.showToast(
                              msg: "创建成功",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.black45,
                              textColor: Colors.white,
                              fontSize: 13.0);
                          Navigator.of(context).pop();
                        }
                      });
                    },
              child: Container(
                child: Center(
                  child: Text("保 存", style: themeData.primaryTextTheme.button),
                ),
                width: 120,
              ),
            )
          ],
        ),
      ),
    );
  }
}
