import 'dart:convert';

import 'package:hello_world/models/ProfileChangeNotifier.dart';

class MusicInfoData extends ProfileChangeNotifier {
  int _playIndex = 0;

  List<MusicInfoModel> _musicInfoModels = [];

  MusicInfoModel get musicInfoModel => cnprofile.musicInfoModel;

  List<MusicInfoModel> get musicInfoModels => _musicInfoModels;

  int get playIndex => _playIndex;

  setPlayIndex(int playIndex) {
    _playIndex = playIndex;
    notifyListeners();
  }

  setMusicInfoModel(MusicInfoModel musicInfoModel) {
    cnprofile.musicInfoModel = musicInfoModel;
    notifyListeners();
  }

  setMusicInfoModels(List<MusicInfoModel> musicInfoModels) {
    _musicInfoModels = musicInfoModels;
    notifyListeners();
  }
}

class MusicInfoModel {
  int id = 0;
  String name = "";
  String path = "";
  String fullpath = "";
  String type = "";
  int rank = 0;
  bool syncstatus = true;
  String title = "";
  String artist = "";
  String album = "";

  MusicInfoModel({
    this.id,
    this.name,
    this.path,
    this.fullpath,
    this.type,
    this.rank,
    this.syncstatus,
    this.title,
    this.artist,
    this.album,
  });

  factory MusicInfoModel.fromMap(Map<String, dynamic> json) =>
      new MusicInfoModel(
        id: json["id"],
        name: json["name"],
        path: json["path"],
        fullpath: json["fullpath"],
        type: json["type"],
        syncstatus: json["syncstatus"] == 1,
        title: json["title"],
        artist: json["artist"],
        album: json["album"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "path": path,
        "fullpath": fullpath,
        "type": type,
        "syncstatus": syncstatus,
        "title": title,
        "artist": artist,
        "album": album,
      };

  Map toJson() {
    Map map = new Map();
    map["id"] = this.id;
    map["name"] = this.name;
    map["path"] = this.path;
    map["fullpath"] = this.fullpath;
    map["type"] = this.type;
    map["syncstatus"] = this.syncstatus;
    map["title"] = this.title;
    map["artist"] = this.artist;
    map["album"] = this.album;
    return map;
  }

  static MusicInfoModel fromJson(String str) {
    final jsonData = json.decode(str);
    return MusicInfoModel.fromMap(jsonData);
  }
}
