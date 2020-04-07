import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http_server/http_server.dart';
import 'package:path_provider/path_provider.dart';

class MyHttpServer extends StatefulWidget {
  @override
  _MyHttpServerState createState() => _MyHttpServerState();
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
      print(request.uri.toString() + 'hehe');

      switch (request.uri.toString()) {
        case '/upload':
          uploadController(request);
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

  Future<String> uploadController(HttpRequest request) async {
    final file = await _localFile("fileName.mp3");

    HttpBodyHandler.processRequest(request).then((body) {
      HttpBodyFileUpload fileUploaded = body.body['file'];

      file.writeAsBytes(fileUploaded.content, mode: FileMode.WRITE).then((_) {
        request.response.close();
      });
    });
//flutter资源路径，需要提前配置好，保证可用，路径的最后要标注文件名与后缀，例如file.db
    String assetPath;

//存储文件路径，请保证可用
//     String savePath;
// //创建路径
//     new Directory(dirname(path)).create(recursive: true);
// //请确保没有文件已经存在
//     File file = new File(path);
// //写文件
//     file.writeAsBytes(byteData.buffer.asInt8List(0));
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
