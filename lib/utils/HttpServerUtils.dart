import 'dart:convert';
import 'dart:io';

class HttpServerUtils {
  static response(HttpRequest httpRequest, int code, String msg, Map data) {
    var musicInfoJson = "{}";

    Responses response =
        new Responses(Data: data, Code: 200, Message: "Success");
    musicInfoJson = jsonEncode(response);

    httpRequest.response
      ..headers.clear()
      ..headers.contentType =
          new ContentType("application", "json", charset: "UTF-8")
      ..headers.set("Accept-Ranges", "bytes")
      ..headers.set("Connection", "keep-alive")
      ..headers.set("Content-Length", utf8.encode(musicInfoJson).length)
      ..add(utf8.encode(musicInfoJson))
      ..close();
  }
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
