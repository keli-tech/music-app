import 'dart:convert';

class CloudServiceModel {
  int id = 0;
  String name = "";
  String assetspath = "";
  String type = "";
  String url = "";
  String host = "";
  String port = "";
  String account = "";
  String password = "";
  bool signedin = false;
  int updatetime = 0;

  CloudServiceModel({
    required this.id,
    required this.name,
    required this.assetspath,
    required this.type,
    required this.url,
    required this.host,
    required this.port,
    required this.account,
    required this.password,
    required this.signedin,
    required this.updatetime,
  });

  factory CloudServiceModel.fromMap(Map<String, dynamic> json) =>
      new CloudServiceModel(
        id: json["id"],
        name: json["name"],
        assetspath: json["assetspath"],
        type: json["type"],
        url: json["url"],
        host: json["host"],
        port: json["port"],
        account: json["account"],
        password: json["password"],
        updatetime: json["updatetime"],
        signedin: json["signedin"] == 1,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "assetspath": assetspath,
        "type": type,
        "url": url,
        "host": host,
        "port": port,
        "account": account,
        "password": password,
        "signedin": signedin,
        "updatetime": updatetime,
      };

  String toJson() {
    final a = this.toMap();
    return json.encode(a);
  }

  static CloudServiceModel fromJson(String str) {
    final jsonData = json.decode(str);
    return CloudServiceModel.fromMap(jsonData);
  }
}
