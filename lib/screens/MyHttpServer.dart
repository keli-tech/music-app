import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:dart_tags/dart_tags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hello_world/models/MusicPlayListModel.dart';
import 'package:hello_world/services/AdmobService.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:http_server/http_server.dart';
import 'package:path_provider/path_provider.dart';

import '../models/MusicInfoModel.dart';
import '../services/Database.dart';

class MyHttpServer extends StatefulWidget {
  static const String className = 'MyHttpServer';

  @override
  _MyHttpServerState createState() => _MyHttpServerState();
}

class Responses {
  final Map Data;
  final int Code;
  final String Message;

  Responses({
    this.Data,
    this.Code,
    this.Message,
  });

  Map toJson() {
    Map map = new Map();
    map["Data"] = this.Data;
    map["Code"] = this.Code;
    map["Message"] = this.Message;
    return map;
  }
}

class _MyHttpServerState extends State<MyHttpServer> {
  String serverUrl = "";
  HttpServer server;
  bool serverStarted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (server != null) {
      print("http server disposed!!");
      server.close(force: true);
    }
    super.dispose();
  }

  _startServer() async {
    var hostIp = '127.0.0.1';
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.address.startsWith("1")) {
          hostIp = addr.address;
          break;
        }
      }
    }

    setState(() {
      serverStarted = true;
      serverUrl = 'http://${hostIp}:8080';
    });
    server = await HttpServer.bind(
      hostIp,
      8080,
    );

    await for (var request in server) {
      switch (request.uri.toString().split("?").first) {
        case '/upload':
          uploadController(request);
          break;
        case '/musicList':
          musicListController(request);
          break;
        case '/deleteMusicInfo':
          deleteMusicController(request);
          break;
        case '/createFold':
          createFoldController(request);
          break;
        case '/':
          homeController(request);
          break;
        default:
          publicController(request);
          break;
      }
    }
    // setState(() {
    //   statusText = "Server running on IP : " +
    //       server.address.toString() +
    //       " On Port : " +
    //       server.port.toString();
    // });
  }

  _stopServer() async {
    server.close(force: true);
    setState(() {
      serverStarted = false;
    });
  }

  Future<String> musicListController(HttpRequest request) async {
    HttpBodyHandler.processRequest(request).then((body) async {
      String musicPath = request.uri.queryParameters["path"];
      var musicInfoJson = "[";

      DBProvider.db.getMusicInfoByPath(musicPath).then((onValue) {
        Map map = new Map();
        map["List"] = onValue;
        map["Total"] = onValue.length;
        Responses response =
            new Responses(Data: map, Code: 200, Message: "Success");
        musicInfoJson = jsonEncode(response);

        request.response
          ..headers.clear()
          ..headers.contentType =
              new ContentType("application", "json", charset: "UTF-8")
          ..headers.set("Accept-Ranges", "bytes")
          ..headers.set("Connection", "keep-alive")
          ..headers.set("Content-Length", utf8.encode(musicInfoJson).length)
          ..add(utf8.encode(musicInfoJson))
          ..close();
      });
    });
  }

  Future<String> deleteMusicController(HttpRequest request) async {
    // todo 处理列表数据；

    HttpBodyHandler.processRequest(request).then((body) async {
      int musicID = int.parse(request.uri.queryParameters["id"]);
      var musicInfoJson = "";

      DBProvider.db.getMusic(musicID).then((musicInfoModel) async {
        final file = await _localFile(musicInfoModel.fullpath);
        file.delete(recursive: true);

        await DBProvider.db.deleteMusic(musicID);

        Responses response =
            new Responses(Data: new Map(), Code: 200, Message: "Success");
        musicInfoJson = jsonEncode(response);

        request.response
          ..headers.clear()
          ..headers.contentType =
              new ContentType("application", "json", charset: "UTF-8")
          ..headers.set("Accept-Ranges", "bytes")
          ..headers.set("Connection", "keep-alive")
          ..headers.set("Content-Length", utf8.encode(musicInfoJson).length)
          ..add(utf8.encode(musicInfoJson))
          ..close();
      });
    });
  }

  Future<String> createFoldController(HttpRequest request) async {
    HttpBodyHandler.processRequest(request).then((body) async {
      String foldPath = body.body['path'];
      String foldName = body.body['name'];

      var musicInfoJson = "";

      try {
        MusicInfoModel musicInfoModel =
            await DBProvider.db.getFoldByPathName(foldPath, foldName);
        if (musicInfoModel != null && musicInfoModel.id > 0) {
          Responses response =
              new Responses(Data: new Map(), Code: 100, Message: "Failed");
          musicInfoJson = jsonEncode(response);
        } else {
          MusicInfoModel newMusicInfo = MusicInfoModel(
              name: foldName,
              path: foldPath,
              fullpath: foldPath + foldName + "/",
              type: MusicInfoModel.TYPE_FOLD,
              sort: 1,
              updatetime: new DateTime.now().millisecondsSinceEpoch,
              syncstatus: true);

          await DBProvider.db.newMusicInfo(newMusicInfo);

          final path = await _localPath;

          var dir = await new Directory(path + foldPath + foldName + "/")
              .create(recursive: true);

          Responses response =
              new Responses(Data: new Map(), Code: 200, Message: "Success");
          musicInfoJson = jsonEncode(response);
        }
      } catch (e) {
        print(e);

        Responses response =
            new Responses(Data: new Map(), Code: 100, Message: "Failed");
        musicInfoJson = jsonEncode(response);
      }

      request.response
        ..headers.clear()
        ..headers.contentType =
            new ContentType("application", "json", charset: "UTF-8")
        ..headers.set("Accept-Ranges", "bytes")
        ..headers.set("Connection", "keep-alive")
        ..headers.set("Content-Length", utf8.encode(musicInfoJson).length)
        ..add(utf8.encode(musicInfoJson))
        ..close();
    });
  }

  Future<String> uploadController(HttpRequest request) async {
    HttpBodyHandler.processRequest(request).then((body) async {
      HttpBodyFileUpload fileUploaded = body.body['file'];
      String musicPath = body.body['path'];

      var file = await _localFile(musicPath + fileUploaded.filename);
      // 保存文件
      file
          .writeAsBytes(fileUploaded.content, mode: FileMode.WRITE)
          .then((_) async {
        //todo size
        int fileLength = await file.length();
        String fileSize = Uri.decodeComponent(
            (fileLength / 1024 / 1024).toStringAsFixed(2).toString() + "MB");

        request.response.close();

        // 保存到数据库
        // todo bugfix, 部分无tab mp3 未读取到 tag，会卡住, 比如flac
        TagProcessor tp = new TagProcessor();

        var l = await tp.getTagsFromByteArray(file.readAsBytes());

        AttachedPicture picture;
        String title = fileUploaded.filename;
        String artist = "未知";
        String album = "未知";

        l.forEach((f) {
          if (f.tags != null && f.tags.containsKey("picture")) {
            // 保存音乐文件表
            picture = f.tags["picture"];
            title = f.tags["title"];
            artist = f.tags["artist"];
            album = f.tags["album"];
          }
        });

        MusicInfoModel newMusicInfo = MusicInfoModel(
          name: fileUploaded.filename,
          path: musicPath,
          fullpath: musicPath + fileUploaded.filename,
          type: fileUploaded.filename.split(".").last.toLowerCase(),
          syncstatus: true,
          title: title,
          artist: artist,
          filesize: fileSize,
          album: album,
          sort: 100,
          updatetime: new DateTime.now().millisecondsSinceEpoch,
        );
        int newMid = await DBProvider.db.newMusicInfo(newMusicInfo);

        // 添加到专辑表
        MusicPlayListModel newMusicPlayListModel = MusicPlayListModel(
          name: album,
          type: MusicPlayListModel.TYPE_ALBUM,
          artist: artist,
          sort: 100,
        );
        int newPlid =
            await DBProvider.db.newMusicPlayList(newMusicPlayListModel);
        if (newPlid > 0 && newMid > 0) {
          // 保存到列表
          await DBProvider.db.addMusicToPlayList(newPlid, newMid);
        }

        // 保存音乐封面
        if (picture.imageData != null) {
          var dir = await FileManager.musicAlbumPicturePath(artist, album)
              .create(recursive: true);
          var imageFile =
              await FileManager.musicAlbumPictureFile(artist, album);
          imageFile
              .writeAsBytes(picture.imageData, mode: FileMode.WRITE)
              .then((_) async {});
        }
      });
    });
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> _localFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName');
  }

  homeController(HttpRequest request) {
    String fielPath = "assets/httpserver/public/index.html";
    String type1 = 'text';
    String type2 = 'html';
    type2 = 'html';
    rootBundle.load(fielPath).then((value) {
      request.response
        ..headers.clear()
        ..headers.contentType = new ContentType(type1, type2, charset: "UTF-8")
        ..headers.set("Accept-Ranges", "bytes")
        ..headers.set("Connection", "keep-alive")
        ..headers.set("Content-Length", value.lengthInBytes)
        ..write(utf8.decode(value.buffer.asUint8List()))
        ..close();
    });
  }

// http 的公开资源
  publicController(HttpRequest request) {
    String fielPath = "assets/httpserver/public" + request.uri.path.toString();
    String filetype = fielPath.split('.').last;
    String type1 = 'text';
    String type2 = 'html';
    if (filetype == 'html') {
      type2 = 'html';
    } else if (filetype == 'js') {
      type1 = 'application';
      type2 = 'javascript';
    } else if (filetype == 'css') {
      type2 = 'css';
    } else if (filetype == 'ico') {
      type2 = 'ico';
    } else if (filetype == 'map') {
      type2 = 'html';
    } else if (filetype == 'woff') {
      type1 = 'font';
      type2 = 'woff';
    }

    // runZoned 捕获异步异常
    runZoned(() {
      if (type2 == "woff" || type2 == "ttf" || type2 == "ico") {
        rootBundle.load(fielPath).then((value) {
          request.response
            ..headers.clear()
            ..headers.contentType =
                new ContentType(type1, type2, charset: "UTF-8")
            ..headers.set("Accept-Ranges", "bytes")
            ..headers.set("Connection", "keep-alive")
            ..headers.set("Content-Length", value.lengthInBytes)
            ..add(value.buffer.asUint8List())
            ..close();
        });
      } else {
        rootBundle.load(fielPath).then((value) {
          request.response
            ..headers.clear()
            ..headers.contentType =
                new ContentType(type1, type2, charset: "UTF-8")
            // new ContentType("application", "octet-stream")
            // ..write('Hello, world')
            ..headers.set("Accept-Ranges", "bytes")
            ..headers.set("Connection", "keep-alive")
            ..headers.set("Content-Length", value.lengthInBytes)
            ..write(utf8.decode(value.buffer.asUint8List()))
            ..close();
        });
      }
    }, onError: (Object obj, StackTrace stack) {
      print(obj);
      print(stack);
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Scaffold(
      appBar: CupertinoNavigationBar(
        middle: Text(
          'Wi-Fi同步文件',
        ),
        backgroundColor: themeData.backgroundColor,
      ),
      backgroundColor: themeData.backgroundColor,
      body: Builder(
        builder: buildBody,
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(left: 5, top: 0, right: 5, bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            child: AdmobBanner(
              adUnitId: AdMobService.getBannerAdUnitId(MyHttpServer.className),
              adSize: AdmobBannerSize.FULL_BANNER,
              listener: (AdmobAdEvent event, Map<String, dynamic> args) {
                AdMobService.handleEvent(event, args, 'Banner');
              },
            ),
          ),
          SizedBox(
            height: 70,
          ),
          AnimatedSwitcher(
            transitionBuilder: (child, anim) {
              return ScaleTransition(child: child, scale: anim);
            },
            switchInCurve: Curves.fastLinearToSlowEaseIn,
            switchOutCurve: Curves.fastOutSlowIn,
            duration: Duration(milliseconds: 400),
            child: serverStarted == false
                ? RaisedButton(
                    padding: EdgeInsets.only(
                        left: 30, top: 15, right: 30, bottom: 15),
                    key: Key("stop"),
                    color: themeData.primaryColor,
                    onPressed: () {
                      _startServer();
                    },
                    child: Text("启动Wi-Fi同步文件服务",
                        style: themeData.primaryTextTheme.button),
                  )
                : RaisedButton(
                    key: Key("start"),
                    padding: EdgeInsets.only(
                        left: 30, top: 15, right: 30, bottom: 15),
                    color: Colors.red,
                    onPressed: () {
                      _stopServer();
                    },
                    child: Text("停止Wi-Fi同步文件服务",
                        style: themeData.primaryTextTheme.button),
                  ),
          ),
          SizedBox(
            height: 30,
          ),
          Text(
            "手机与电脑连接到同一个Wi-Fi网络，可以通过电脑端web浏览器来传输文件。",
            style: themeData.textTheme.subtitle,
          ),
          SizedBox(
            height: 30,
          ),
          serverStarted == true
              ? Column(
                  children: <Widget>[
                    ListTile(
                      title: new Text(
                        '在电脑端浏览器中输入以下 url:',
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: new Text(
                        serverUrl,
                      ),
                      leading: Icon(
                        Icons.desktop_mac,
                        color: themeData.primaryColor,
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.content_copy),
                        color: themeData.primaryColor,
                        onPressed: () {
                          // 复制 copy url
                          ClipboardData data =
                              new ClipboardData(text: serverUrl);
                          Clipboard.setData(data).then((onValue) {
                            print("copy that");
                          });

                          Scaffold.of(context).showSnackBar(new SnackBar(
                              backgroundColor: themeData.highlightColor,
                              content: Container(
                                height: 70,
                                child: new Text(
                                  "已复制 url !",
                                ),
                              )));
                        },
                      ),
                    ),
                  ],
                )
              : Text(""),
        ],
      ),
    );
  }
}
