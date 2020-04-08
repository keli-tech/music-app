import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_tags/dart_tags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http_server/http_server.dart';
import 'package:path_provider/path_provider.dart';

import '../models/MusicInfoModel.dart';
import '../services/Database.dart';

class MyHttpServer extends StatefulWidget {
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
  String statusText = "Start Server";
  HttpServer server;

  startServer() async {
    var hostIp = '127.0.0.1';
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        hostIp = addr.address;
        if (hostIp.startsWith("1")) {
          print('${addr.address} IP');
          break;
        }
      }
    }
    print(hostIp);

    setState(() {
      statusText = 'Starting server on ${hostIp} Port : 8080';
    });
    server = await HttpServer.bind(
      hostIp,
      8080,
    );
    print("Server running on IP : " +
        server.address.toString() +
        " On Port : " +
        server.port.toString());

    await for (var request in server) {
      print(request.uri.toString().split("?").first);

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

  stopServer() async {
    server.close(force: true);
    setState(() {});
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

      MusicInfoModel musicInfoModel =
          await DBProvider.db.getFoldByPathName(foldPath, foldName);
      if (musicInfoModel != null && musicInfoModel.id > 0) {
      } else {
        MusicInfoModel newMusicInfo = MusicInfoModel(
            name: foldName,
            path: foldPath,
            fullpath: foldPath + foldName + "/",
            type: 'fold',
            syncstatus: true);

        await DBProvider.db.newMusicInfo(newMusicInfo);

        final path = await _localPath;

        var dir = await new Directory(path + foldPath + foldName + "/")
            .create(recursive: true);
      }

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
  }

  Future<String> uploadController(HttpRequest request) async {
    HttpBodyHandler.processRequest(request).then((body) async {
      HttpBodyFileUpload fileUploaded = body.body['file'];
      String musicPath = body.body['path'];

      var file = await _localFile(musicPath + fileUploaded.filename);

      file
          .writeAsBytes(fileUploaded.content, mode: FileMode.WRITE)
          .then((_) async {
        MusicInfoModel newMusicInfo = MusicInfoModel(
            name: fileUploaded.filename,
            path: musicPath,
            fullpath: musicPath + fileUploaded.filename,
            type: fileUploaded.filename.split(".").last.toLowerCase(),
            syncstatus: true);

        await DBProvider.db.newMusicInfo(newMusicInfo);
        request.response.close();

        // todo bugfix, 部分无tab mp3 未读取到 tag，会卡住,
        TagProcessor tp = new TagProcessor();
//        tp
//            .getTagsFromByteArray(file.readAsBytes())
//            .then((l) => l.forEach((f) => print(f)));
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
        // new ContentType("application", "octet-stream")
        // ..write('Hello, world')
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

        // rootBundle.loadString(fielPath).then((value) {
        //   request.response
        //     ..headers.contentType =
        //         // new ContentType(type1, type2, charset: "utf-8")
        //         new ContentType("application", "octet-stream")
        //     // ..write('Hello, world')
        //     ..write(value)
        //     ..close();
        // });
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
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            onPressed: () {
              startServer();
            },
            child: Text(statusText),
          ),
          RaisedButton(
            onPressed: () {
              stopServer();
            },
            child: Text("stop server"),
          )
        ],
      ),
    ));
  }
}
