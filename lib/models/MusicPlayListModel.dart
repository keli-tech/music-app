import 'dart:convert';

//
//"type TEXT,"
//"name TEXT,"
//"sort INTEGER,"
//"imgpath TEXT"

class MusicPlayListModel {
  int id = 0;
  String type = "";
  String name = "";
  String artist = "";
  String year = "";
  int sort = 0;
  String imgpath = "";
  int updatetime = 0;
  int musiccount = 0;

  static int FAVOURITE_PLAY_LIST_ID = 1;

  static String TYPE_PLAY_LIST = 'playlist';
  static String TYPE_SCEEN = 'sceen';
  static String TYPE_ALBUM = 'album';
  static String TYPE_FAV = 'fav';

  MusicPlayListModel({
    this.id,
    this.name,
    this.artist,
    this.year,
    this.type,
    this.sort,
    this.imgpath,
    this.updatetime,
    this.musiccount,
  });

  factory MusicPlayListModel.fromMap(Map<String, dynamic> json) =>
      new MusicPlayListModel(
        id: json["id"],
        name: json["name"],
        artist: json["artist"],
        year: json["year"],
        type: json["type"],
        sort: json["sort"],
        imgpath: json["imgpath"],
        updatetime: json["updatetime"],
        musiccount: json["musiccount"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "artist": artist,
        "year": year,
        "type": type,
        "sort": sort,
        "imgpath": imgpath,
        "updatetime": updatetime,
        "musiccount": musiccount,
      };

  Map toJson() {
    Map map = new Map();
    map["id"] = this.id;
    map["name"] = this.name;
    map["type"] = this.type;
    map["sort"] = this.sort;
    map["imgpath"] = this.imgpath;
    map["updatetime"] = this.updatetime;
    map["musiccount"] = this.musiccount;
    return map;
  }

  static MusicPlayListModel fromJson(String str) {
    final jsonData = json.decode(str);
    return MusicPlayListModel.fromMap(jsonData);
  }
}
