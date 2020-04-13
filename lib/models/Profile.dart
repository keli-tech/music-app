import 'dart:convert';

import 'package:hello_world/models/MusicInfoModel.dart';

class Profile {
  int id;
  MusicInfoModel musicInfoModel;
  List<MusicInfoModel> musicInfoModelList;
  String lastName;
  bool blocked;
  String documentDirectory;

  Profile({
    this.id,
    this.musicInfoModel,
    this.musicInfoModelList,
    this.lastName,
    this.blocked,
    this.documentDirectory,
  });

  factory Profile.fromMap(Map<String, dynamic> json) => new Profile(
        id: json["id"],
        musicInfoModel: MusicInfoModel.fromJson(jsonEncode(json["musicInfoModel"])),
        musicInfoModelList: json["musicInfoModelList"],
        lastName: json["last_name"],
        blocked: json["blocked"] == 1,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "musicInfoModel": musicInfoModel,
        "musicInfoModelList": musicInfoModelList,
        "last_name": lastName,
        "blocked": blocked,
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
