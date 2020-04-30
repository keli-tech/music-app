import 'dart:convert';

import 'package:hello_world/models/MusicInfoModel.dart';

class Profile {
  int id = 0;
  MusicInfoModel musicInfo;
  List<MusicInfoModel> musicInfoList = [];
  List<MusicInfoModel> musicInfoFavList = [];
  int playIndex = 0;
  PlayMode playMode;

  String documentDirectory;

  Profile({
    this.id,
    this.musicInfo,
    this.musicInfoList,
    this.musicInfoFavList,
    this.playIndex,
    this.documentDirectory,
    this.playMode,
  });

  factory Profile.fromMap(Map<String, dynamic> json) {
    var a = List.castFrom(json["musicInfoList"]);
    List<MusicInfoModel> musicInfoList = a.isNotEmpty
        ? a.map((item) {
            MusicInfoModel m = MusicInfoModel.fromMap(item);
            return m;
          }).toList()
        : [];

    return new Profile(
      id: json["id"],
      musicInfo: MusicInfoModel.fromJson(jsonEncode(json["musicInfo"])),
      musicInfoList: musicInfoList,
      musicInfoFavList: json["musicInfoFavList"],
      playIndex: json["playIndex"],
      playMode: getPlayModeFromString(json["playMode"]),
      documentDirectory: json["documentDirectory"],
    );
  }

  static PlayMode getPlayModeFromString(String statusAsString) {
    for (PlayMode element in PlayMode.values) {
      if (element.toString() == statusAsString) {
        return element;
      }
    }
    return null;
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "musicInfo": musicInfo,
        "musicInfoList": musicInfoList,
        "musicInfoFavList": musicInfoFavList,
        "playIndex": playIndex,
        "playMode": playMode.toString(),
        "documentDirectory": documentDirectory,
      };

  static Profile fromJson(String str) {
    final jsonData = json.decode(str);
    try {
      return Profile.fromMap(jsonData);
    } catch (error) {
      print(error);
      return null;
    }
  }

  String toJson() {
    final dyn = this.toMap();
    try {
      return json.encode(dyn);
    } catch (error) {
      print(error);
      return "";
    }
  }
}
