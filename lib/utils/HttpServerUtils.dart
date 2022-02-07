import 'dart:convert';
import 'dart:io';

class HttpServerUtils {

  static response(HttpRequest httpRequest, int code, String msg, Map data) {
    var resp = "{}";

    Responses response =
        new Responses(data: data, code: 200, message: "Success");
    resp = jsonEncode(response);

    httpRequest.response
      ..headers.clear()
      ..headers.contentType =
          new ContentType("application", "json", charset: "UTF-8")
      ..headers.set("Accept-Ranges", "bytes")
      ..headers.set("Connection", "keep-alive")
      ..headers.set("Content-Length", utf8.encode(resp).length)
      ..add(utf8.encode(resp))
      ..close();
  }

}

class Responses {

  final Map data;
  final int code;
  final String message;

  Responses({this.data, this.code, this.message});

  Map toJson() {
    Map map = new Map();
    map["Data"] = this.data;
    map["Code"] = this.code;
    map["Message"] = this.message;
    return map;
  }
}
