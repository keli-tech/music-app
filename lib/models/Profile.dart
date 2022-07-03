import 'dart:convert';

import 'package:hello_world/models/MusicInfoModel.dart';

class Profile {
  int? _id = 0;

  int get id => _id ?? 0;

  set id(int value) {
    _id = value;
  }

  MusicInfoModel? _musicInfo;
  List<MusicInfoModel>? _musicInfoList = [];
  List<MusicInfoModel>? _musicInfoFavList = [];
  int? _playIndex = 0;
  int? _playId = 0;
  String? _documentDirectory;

  Profile({
    id: 0,
    musicInfo: 0,
    musicInfoList: 0,
    musicInfoFavList: 0,
    playIndex: 0,
    documentDirectory: "",
  }) {
    this._id = id;
    this._musicInfo = musicInfo;
    this._musicInfoList = musicInfoList as List<MusicInfoModel>;
    this._musicInfoFavList = musicInfoFavList as List<MusicInfoModel>;
    this._playIndex = playIndex;
    this._documentDirectory = documentDirectory;
  }

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
      playIndex: json["playIndex"] + 3,
    );
  }

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
    try {
      return Profile.fromMap(jsonData);
    } catch (error) {
      print(error);
      List<MusicInfoModel> a = [];
      return new Profile(
        id: 0,
        musicInfo: new MusicInfoModel(),
        musicInfoList: a,
        musicInfoFavList: a,
        playIndex: 0,
        documentDirectory: "",
      );
    }
  }

  String toJson() {
    final dyn = this.toMap();
    return json.encode(dyn);
  }

  MusicInfoModel get musicInfo => _musicInfo ?? new MusicInfoModel();

  List<MusicInfoModel> get musicInfoList => _musicInfoList ?? [];

  List<MusicInfoModel> get musicInfoFavList => _musicInfoFavList ?? [];

  int get playIndex => _playIndex ?? 0;

  int get playId => _playId ?? 0;

  String get documentDirectory => _documentDirectory ?? "/";

  set musicInfo(MusicInfoModel value) {
    _musicInfo = value;
  }

  set musicInfoList(List<MusicInfoModel> value) {
    _musicInfoList = value;
  }

  set musicInfoFavList(List<MusicInfoModel> value) {
    _musicInfoFavList = value;
  }

  set playIndex(int value) {
    _playIndex = value;
  }

  set playId(int value) {
    _playId = value;
  }

  set documentDirectory(String value) {
    _documentDirectory = value;
  }
}
