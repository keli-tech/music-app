import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:hello_world/models/ProfileChangeNotifier.dart';
import 'package:hello_world/services/Database.dart';

class MusicInfoData extends ProfileChangeNotifier {
  int _playIndex = 0;
  AudioPlayerState _audioPlayerState = AudioPlayerState.STOPPED;
  List<MusicInfoModel> _musicInfoList = [];
  Set<int> _musicInfoFavIDSet = Set<int>();

//  MusicInfoModel get musicInfoModel => cnprofile.musicInfoModel;
  MusicInfoModel get musicInfoModel => _musicInfoList.length > _playIndex
      ? _musicInfoList[_playIndex]
      : MusicInfoModel();

  List<MusicInfoModel> get musicInfoList => _musicInfoList;

  Set<int> get musicInfoFavIDSet => _musicInfoFavIDSet;

  int get playIndex => _playIndex;

  AudioPlayerState get audioPlayerState => _audioPlayerState;

  setAudioPlayerState(AudioPlayerState audioPlayerState) {
    _audioPlayerState= audioPlayerState;
    notifyListeners();
  }

  setPlayIndex(int playIndex) {
    _playIndex = playIndex;
    notifyListeners();
  }

  setMusicInfoList(List<MusicInfoModel> musicInfoModels) {
    _musicInfoList = musicInfoModels;
    notifyListeners();
  }

  setMusicInfoFavIDSet(Set<int> musicInfoFavIDSet) {
    _musicInfoFavIDSet = musicInfoFavIDSet;
    notifyListeners();
  }

  addMusicInfoFavIDSet(int mid) {
    DBProvider.db.addMusicToFavPlayList(mid).then((res) {
      _musicInfoFavIDSet.add(mid);
      notifyListeners();
    });
  }

  removeMusicInfoFavIDSet(int mid) {
    DBProvider.db.deleteMusicFromFavPlayList(mid).then((res) {
      _musicInfoFavIDSet.remove(mid);
      notifyListeners();
    });
  }
}

class MusicInfoModel {
  int id = 0;
  String name = "";
  String path = "";
  String fullpath = "";
  String type = "";
  int sort = 0;
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
    this.sort,
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
        sort: json["sort"],
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
        "sort": sort,
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
    map["sort"] = this.sort;
    return map;
  }

  static MusicInfoModel fromJson(String str) {
    final jsonData = json.decode(str);
    return MusicInfoModel.fromMap(jsonData);
  }
}
