import 'dart:convert';

import 'package:hello_world/models/MusicInfoModel.dart';

class Profile {
  int id;
  MusicInfoModel musicInfo;
  List<MusicInfoModel> musicInfoList;
  List<MusicInfoModel> musicInfoFavList;
  int playIndex;

  String documentDirectory;

  Profile({
    this.id,
    this.musicInfo,
    this.musicInfoList,
    this.musicInfoFavList,
    this.playIndex,
    this.documentDirectory,
  });

  factory Profile.fromMap(Map<String, dynamic> json) => new Profile(
        id: json["id"],
        musicInfo: MusicInfoModel.fromJson(jsonEncode(json["musicInfo"])),
        musicInfoList: json["musicInfoList"],
        musicInfoFavList: json["musicInfoFavList"],
        playIndex: json["playIndex"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "musicInfo": musicInfo,
        "musicInfoList": musicInfoList,
        "musicInfoFavList": musicInfoFavList,
        "playIndex": playIndex,
        "documentDirectory": documentDirectory,
      };

  static Profile fromJson(String str) {
    final jsonData = json.decode(str);
    return Profile.fromMap(jsonData);
  }

  String toJson() {
    final dyn = this.toMap();
    return json.encode(dyn);
  }
}
