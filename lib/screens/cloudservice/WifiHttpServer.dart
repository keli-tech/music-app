import 'dart:async';
import 'dart:convert';
import 'dart:io';

// import 'package:admob_flutter/admob_flutter.dart';
import 'package:dart_tags/dart_tags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hello_world/common/Global.dart';
import 'package:hello_world/components/Tile.dart';
import 'package:hello_world/models/MusicPlayListModel.dart';
import 'package:network_info_plus/network_info_plus.dart';

// import 'package:hello_world/services/AdmobService.dart3';
import 'package:hello_world/services/FileManager.dart';
import 'package:hello_world/utils/HttpServerUtils.dart';
import 'package:http_server/http_server.dart';
import 'package:logging/logging.dart';

import '../../models/MusicInfoModel.dart';
import '../../services/Database.dart';

class WifiHttpServer extends StatefulWidget {
  static const String className = 'WifiHttpServer';

  @override
  _WifiHttpServerState createState() => _WifiHttpServerState();
}

class _WifiHttpServerState extends State<WifiHttpServer> {
  String serverUrl = "";
  HttpServer? server;
  bool serverStarted = false;
  Logger _logger = new Logger(WifiHttpServer.className);
  final info = NetworkInfo();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    server?.close(force: true);
    super.dispose();
  }

  _startServer() async {
    String hostIp = '';
    hostIp = await info.getWifiIP() ?? '127.0.0.1';

    setState(() {
      serverStarted = true;
      serverUrl = 'http://$hostIp:8080';
    });

    // todo 检测端口占用情况
    server = await HttpServer.bind(
      hostIp,
      8080,
    );

    // runZoned 捕获异步异常
    var runZoned2 = runZoned(() async {
      await for (var request in server!) {
        switch (request.uri.toString().split("?").first) {
          case '/upload':
            _uploadController(request);
            break;
          case '/musicList':
            _musicListController(request);
            break;
          case '/deleteMusicInfo':
            _deleteMusicController(request);
            break;
          case '/createFold':
            _createFoldController(request);
            break;
          case '/':
            _homeController(request);
            break;
          case '':
            _homeController(request);
            break;
          default:
            _publicController(request);
            break;
        }
      }
    }, onError: (Object obj, StackTrace stack) {
      print(obj);
      print(stack);
    });
  }

  _stopServer() async {
    if (server != null) {
      server?.close(force: true);
    }

    setState(() {
      serverStarted = false;
    });
  }

  // 列表页
  _musicListController(HttpRequest request) async {
    HttpBodyHandler.processRequest(request).then((body) async {
      String musicPath = request.uri.queryParameters["path"]!;

      DBProvider.db.getMusicInfoByPath(musicPath).then((onValue) {
        Map map = new Map();
        map["List"] = onValue;
        map["Total"] = onValue.length;

        HttpServerUtils.response(request, 200, "Success", map);
      });
    });
  }

  // 删除文件和文件夹
  _deleteMusicController(HttpRequest request) async {
    HttpBodyHandler.processRequest(request).then((body) async {
      int musicID = int.parse(request.uri.queryParameters["id"]!);
      var musicInfoJson = "";

      DBProvider.db.getMusic(musicID).then((musicInfoModel) async {
        final file = FileManager.localFile(musicInfoModel.fullpath);
        file.delete(recursive: true);

        await DBProvider.db.deleteMusic(musicID);

        Responses response =
            new Responses(data: new Map(), code: 200, message: "Success");
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

  // 创建文件夹
  _createFoldController(HttpRequest request) async {
    HttpBodyHandler.processRequest(request).then((body) async {
      String foldPath = body.body['path'];
      String foldName = body.body['name'];

      var musicInfoJson = "";

      try {
        MusicInfoModel? musicInfoModel =
            await DBProvider.db.getFoldByPathName(foldPath, foldName);
        if (musicInfoModel != null && musicInfoModel.id > 0) {
          Responses response =
              new Responses(data: new Map(), code: 100, message: "Failed");
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

          final path = FileManager.localPathDirectory();
          var dir = await new Directory(path + foldPath + foldName + "/")
              .create(recursive: true);

          Responses response =
              new Responses(data: new Map(), code: 200, message: "Success");
          musicInfoJson = jsonEncode(response);
        }
      } catch (e) {
        print(e);

        Responses response =
            new Responses(data: new Map(), code: 100, message: "Failed");
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

  // 上传文件
  _uploadController(HttpRequest request) async {
    HttpBodyHandler.processRequest(request).then((body) async {
      HttpBodyFileUpload fileUploaded = body.body['file'];
      String musicPath = body.body['path'];

      var file = FileManager.localFile(musicPath + fileUploaded.filename);
      // 保存文件
      file
          .writeAsBytes(fileUploaded.content, mode: FileMode.write)
          .then((_) async {
        // 保存文件

        FileManager.saveAudioFileInfo(file, musicPath, fileUploaded.filename);

        // 上次完成则立即关闭 http 连接
        request.response.close();
      });
    });
  }

  // 首页
  _homeController(HttpRequest request) {
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

// http 的静态资源资源
  _publicController(HttpRequest request) {
    String filePath = "assets/httpserver/public" + request.uri.path.toString();
    String filetype = filePath.split('.').last;
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
    } else if (filetype == 'png') {
      type1 = 'image';
      type2 = 'png';
    } else if (filetype == 'map') {
      type2 = 'html';
    } else if (filetype == 'woff') {
      type1 = 'font';
      type2 = 'woff';
    }

    if (type2 == "woff" || type2 == "ttf" || type2 == "ico" || type2 == "png") {
      rootBundle.load(filePath).then((value) {
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
      rootBundle.load(filePath).then((value) {
        request.response
          ..headers.clear()
          ..headers.contentType =
              new ContentType(type1, type2, charset: "UTF-8")
          ..headers.set("Accept-Ranges", "bytes")
          ..headers.set("Connection", "keep-alive")
          ..headers.set("Content-Length", value.lengthInBytes)
          ..write(utf8.decode(value.buffer.asUint8List()))
          ..close();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Scaffold(
      appBar: CupertinoNavigationBar(
        middle: Text(
          'Wi-Fi同步文件',
          style: themeData.primaryTextTheme.headline6,
        ),
        backgroundColor: themeData.backgroundColor,
      ),
      backgroundColor: themeData.backgroundColor,
      body: Builder(
        builder: _buildBody,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    var _windowWidth = MediaQuery.of(context).size.width;

    return Container(
      width: _windowWidth,
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <
          Widget>[
        Global.showAd
            ? Container(
                // child: AdmobBanner(
                //   adUnitId:
                //       AdMobService.getBannerAdUnitId(MyHttpServer.className),
                //   adSize: AdmobBannerSize.FULL_BANNER,
                //   listener: (AdmobAdEvent event, Map<String, dynamic> args) {
                //     AdMobService.handleEvent(event, args, 'Banner');
                //   },
                // ),
                )
            : Container(),
        SizedBox(
          height: 70,
        ),
        Column(
          children: <Widget>[
            AnimatedSwitcher(
              transitionBuilder: (child, anim) {
                return ScaleTransition(child: child, scale: anim);
              },
              switchInCurve: Curves.fastLinearToSlowEaseIn,
              switchOutCurve: Curves.fastOutSlowIn,
              duration: Duration(milliseconds: 400),
              child: serverStarted == false
                  ? Tile(
                      selected: false,
                      radiusnum: 5.0,
                      child: ElevatedButton(
                        key: Key("stop"),
                        style: ElevatedButton.styleFrom(
                            primary: themeData.primaryColorLight,
                            textStyle: TextStyle(fontSize: 16), //字体
                            padding: EdgeInsets.only(
                                left: 30, top: 15, right: 30, bottom: 15)),
                        onPressed: () {
                          _startServer();
                        },
                        child: Text("启动Wi-Fi同步文件服务",
                            style: themeData.primaryTextTheme.button),
                      ))
                  : Tile(
                      selected: false,
                      radiusnum: 5.0,
                      child: ElevatedButton(
                        key: Key("start"),
                        style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                            padding: EdgeInsets.only(
                                left: 30, top: 15, right: 30, bottom: 15)),
                        onPressed: () {
                          _stopServer();
                        },
                        child: Text("停止Wi-Fi同步文件服务",
                            style: themeData.primaryTextTheme.button),
                      ),
                    ),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding:
                  EdgeInsets.only(left: 15, top: 15, right: 15, bottom: 15),
              child: Text(
                "手机与电脑连接到同一个Wi-Fi网络，可以通过电脑端web浏览器来传输文件。",
                style: themeData.primaryTextTheme.subtitle2,
              ),
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
                          style: themeData.primaryTextTheme.headline6,
                        ),
                      ),
                      Divider(),
                      ListTile(
                        title: new Text(
                          serverUrl,
                          style: themeData.primaryTextTheme.headline6,
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
                              _logger.info("复制URL 成功。");
                            });

                            ScaffoldMessenger.of(context)
                                .showSnackBar(new SnackBar(
                                    backgroundColor: themeData.primaryColorDark,
                                    content: Container(
                                      height: 70,
                                      child: new Text(
                                        "已复制 url !",
                                        style: themeData.textTheme.headline6,
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
      ]),
    );
  }
}
