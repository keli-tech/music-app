import 'dart:io';

import 'package:dart_tags/dart_tags.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hello_world/components/Tile.dart';
import 'package:hello_world/models/CloudServiceModel.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/models/MusicPlayListModel.dart';
import 'package:hello_world/screens/cloudservice/LoginCloudServiceScreen.dart';
import 'package:hello_world/screens/cloudservice/WifiHttpServer.dart';
import 'package:hello_world/screens/cloudservice/NextCloudFileScreen.dart';
import 'package:hello_world/services/CloudService.dart';
import 'package:hello_world/services/Database.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:logging/logging.dart';

class CloudServiceScreen extends StatefulWidget {
  @override
  _CloudServiceScreen createState() => _CloudServiceScreen();
}

class _CloudServiceScreen extends State<CloudServiceScreen> {
  List<CloudServiceModel> _cloudServiceModels = [];
  Logger _logger = new Logger("CloudServiceScreen");

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  @override
  void deactivate() {
    super.deactivate();
    _refreshList();
  }

  _refreshList() {
    try {
      CloudService.cs.getCloudServiceList().then((onValue) {
        setState(() {
          _cloudServiceModels = onValue;
        });
      });
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return CupertinoPageScaffold(
      backgroundColor: themeData.backgroundColor,
      child: Scrollbar(
        child: CustomScrollView(
          slivers: <Widget>[
            CupertinoSliverNavigationBar(
              //actionsForegroundColor: themeData.primaryColorDark,
              backgroundColor: themeData.primaryColorLight,
              border: null,
              automaticallyImplyTitle: false,
              automaticallyImplyLeading: false,
              largeTitle: Text(
                "云同步",
                style: TextStyle(
                  color: themeData.primaryColorDark,
                ),
              ),
            ),
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Material(
                      color: themeData.backgroundColor,
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 10),
                            Tile(
                              selected: false,
                              radiusnum: 15.0,
                              child: new ListTile(
                                title: new Text(
                                  'Wi-Fi同步文件',
                                  style: themeData.primaryTextTheme.headline6,
                                ),
                                subtitle: Text(
                                  '手机与电脑连接到同一个Wi-Fi网络，可以通过电脑端web浏览器来传输文件。',
                                  style: themeData.primaryTextTheme.subtitle2,
                                ),
                                leading: new Icon(
                                  Icons.wifi,
                                  color: themeData.primaryColor,
                                ),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: themeData.primaryColor,
                                ),
                                onTap: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .push(CupertinoPageRoute<void>(
                                    title: "Wi-Fi同步文件",
                                    builder: (BuildContext context) =>
                                        WifiHttpServer(
                                            // color: color,
                                            // colorName: colorName,
                                            // index: index,
                                            ),
                                  ));
                                },
                              ),
                            ),
                            ListTile(
                              title: new Text(
                                '云服务',
                                style: themeData.primaryTextTheme.headline6,
                              ),
                            ),
                            Column(
                              children: buildService(context),
                            ),
                            new Divider(),
                            Tile(
                              selected: false,
                              radiusnum: 15.0,
                              child: new ListTile(
                                title: new Text(
                                  '本地文件',
                                  style: themeData.primaryTextTheme.headline6,
                                ),
                                leading: new Icon(
                                  Icons.help,
                                  size: 40,
                                  color: themeData.primaryColor,
                                ),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: themeData.primaryColor,
                                ),
                                onTap: () async {
                                  final typeGroup = XTypeGroup(
                                      label: 'mp3', extensions: ['pdf', 'mp3']);
                                  final files = await openFiles(
                                      acceptedTypeGroups: [typeGroup]);
                                  _logger.info(files);

                                  var a = files.map((file2) {
                                    _logger.info(file2.path);

                                    File fileUploaded = File(file2.path);

                                    var file =
                                        FileManager.localFile("/" + file2.name);

                                    // 保存文件
                                    file
                                        .writeAsBytes(
                                            fileUploaded.readAsBytesSync(),
                                            mode: FileMode.WRITE)
                                        .then((_) async {
                                      int fileLength = await file.length();
                                      String fileSize = Uri.decodeComponent(
                                          (fileLength / 1024 / 1024)
                                                  .toStringAsFixed(2)
                                                  .toString() +
                                              "MB");

                                      // 保存到数据库
                                      // todo bugfix, 部分无tab mp3 未读取到 tag，会卡住, 比如flac
                                      TagProcessor tp = new TagProcessor();

                                      var l = await tp.getTagsFromByteArray(
                                          file.readAsBytes());

                                      AttachedPicture picture;
                                      String title = file2.name;
                                      String artist = "未知";
                                      String album = "未知";

                                      l.forEach((f) {
                                        if (f.tags != null &&
                                            f.tags.containsKey("picture")) {
                                          _logger.info(f.tags["picture"]);
                                          //
                                          // 保存音乐文件表
                                          // picture = f.tags["picture"].cast(AttachedPicture);
                                          picture = (f.tags['picture'] as Map)
                                              .values
                                              .first;

                                          _logger.info(picture);

                                          title = f.tags["title"];
                                          artist = f.tags["artist"];
                                          album = f.tags["album"];
                                        }
                                      });

                                      MusicInfoModel newMusicInfo =
                                          MusicInfoModel(
                                        name: file2.name,
                                        path: "/",
                                        fullpath: "/" + file2.name,
                                        type: file2.name
                                            .split(".")
                                            .last
                                            .toLowerCase(),
                                        syncstatus: true,
                                        title: title,
                                        artist: artist,
                                        filesize: fileSize,
                                        album: album,
                                        sort: 100,
                                        updatetime: new DateTime.now()
                                            .millisecondsSinceEpoch,
                                      );
                                      int newMid = await DBProvider.db
                                          .newMusicInfo(newMusicInfo);

                                      // 添加到专辑表
                                      MusicPlayListModel newMusicPlayListModel =
                                          MusicPlayListModel(
                                        name: album,
                                        type: MusicPlayListModel.TYPE_ALBUM,
                                        artist: artist,
                                        sort: 100,
                                      );
                                      int newPlid = await DBProvider.db
                                          .newMusicPlayList(
                                              newMusicPlayListModel);
                                      if (newPlid > 0 && newMid > 0) {
                                        // 保存到列表
                                        await DBProvider.db.addMusicToPlayList(
                                            newPlid, newMid);
                                      }

                                      // 保存音乐封面
                                      if (picture != null &&
                                          picture.imageData != null) {
                                        var dir = await FileManager
                                                .musicAlbumPicturePath(
                                                    artist, album)
                                            .create(recursive: true);
                                        var imageFile =
                                            FileManager.musicAlbumPictureFile(
                                                artist, album);
                                        imageFile
                                            .writeAsBytes(picture.imageData,
                                                mode: FileMode.WRITE)
                                            .then((_) async {});
                                      }
                                    });

                                    return 1;
                                  });

                                  _logger.info(a);
                                },
                              ),
                            ),
                            Tile(
                              selected: false,
                              radiusnum: 15.0,
                              child: new ListTile(
                                title: new Text(
                                  '帮助文档',
                                  style: themeData.primaryTextTheme.headline6,
                                ),
                                leading: new Icon(
                                  Icons.help,
                                  size: 40,
                                  color: themeData.primaryColor,
                                ),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: themeData.primaryColor,
                                ),
                                onTap: () async {
                                  // const url = 'https://keli.tech/music/help';
                                  // if (await canLaunch(url)) {
                                  //   await launch(url);
                                  // } else {
                                  //   print('Could not launch $url');
                                  // }

                                  FilePickerResult result =
                                      await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['mp3', 'pdf', 'doc'],
                                  );
                                  _logger.info(result);
                                },
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildService(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    var res = _cloudServiceModels.map((item) {
      return Tile(
        selected: false,
        radiusnum: 15.0,
        child: ListTile(
          title: new Text(
            item.name,
            style: themeData.primaryTextTheme.headline6,
          ),
          subtitle: Text(
            item.signedin ? '已连接:' + item.url : '请登录',
            style: themeData.primaryTextTheme.subtitle2,
            maxLines: 1,
          ),
          leading: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              color: Colors.black45,
            ),
            child: Image.asset(
              item.assetspath,
              width: 40,
            ),
          ),
          trailing: Tile(
            selected: false,
            radiusnum: 20,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: themeData.primaryColorDark,
              foregroundColor: themeData.primaryColorLight,
              child: Icon(
                Icons.arrow_forward,
                size: 18,
              ),
            ),
          ),
          onTap: () async {
            if (item.signedin) {
              String indexPath = "/";
              if (item.name.toLowerCase() == '坚果云') {
                indexPath = "dav";
              }

              Navigator.of(
                context,
              ).push(CupertinoPageRoute<void>(
                title: item.name,
                builder: (BuildContext context) => NextCloudFileScreen(
                  title: item.name,
                  path: indexPath,
                  filePath: "/${item.name.toLowerCase()}/",
                  cloudServiceModel: item,
                ),
              ));
            } else {
              Navigator.of(
                context,
              ).push(CupertinoPageRoute<void>(
                title: item.name,
                builder: (BuildContext context) => LoginCloudServiceScreen(
                  title: item.name,
                  cloudServiceModel: item,
                ),
              ));
            }
          },
        ),
      );
    }).toList();

    return res;
  }
}
