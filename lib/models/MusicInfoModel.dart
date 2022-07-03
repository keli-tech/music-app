import 'dart:convert';

import 'package:hello_world/models/ProfileChangeNotifier.dart';
import 'package:hello_world/services/Database.dart';
import 'package:just_audio/just_audio.dart';

//
class MusicInfoData extends ProfileChangeNotifier {
  PlayerState _audioPlayerState = PlayerState(false, ProcessingState.completed);
  Set<int> _musicInfoFavIDSet = Set<int>();

//  MusicInfoModel get musicInfoModel => cnprofile.musicInfoModel;
  MusicInfoModel get musicInfoModel => getMusicInfoModel();

  MusicInfoModel getMusicInfoModel() {
    return cnprofile.musicInfoList.length > cnprofile.playIndex
        ? cnprofile.musicInfoList[cnprofile.playIndex]
        : MusicInfoModel();
  }

  List<MusicInfoModel> get musicInfoList => cnprofile.musicInfoList;

  Set<int> get musicInfoFavIDSet => _musicInfoFavIDSet;

  int get playIndex => cnprofile.playIndex;

  int get playId => cnprofile.playId;

  PlayerState get audioPlayerState => _audioPlayerState;

  setAudioPlayerState(PlayerState audioPlayerState) {
    _audioPlayerState = audioPlayerState;
    notifyListeners();
  }

  setPlayIndex(int playIndex) {
    cnprofile.playIndex = playIndex;
    cnprofile.playId = cnprofile.musicInfoList[playIndex].id;

    notifyListeners();
  }

  setMusicInfoList(List<MusicInfoModel> musicInfoModels) {
    cnprofile.musicInfoList = musicInfoModels;
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
  int? _id = 0;

  set id(int value) {
    _id = value;
  }

  String? _name = "";
  String? _path = "";
  String? _fullpath = "";
  String? _type = "";
  int? _sort = 0;
  bool? _syncstatus = true;
  String? _title = "";
  String? _artist = "";
  String? _album = "";
  String? _picture = "";
  String? _filesize = "";
  String? _sourcepath = "";
  String? _extra = "";
  int? _updatetime = 0;

  String get name => _name ?? "";

  String get path => _path ?? "";

  String get fullpath => _fullpath ?? "";

  String get type => _type ?? "";

  int get sort => _sort ?? 0;

  bool get syncstatus => _syncstatus ?? false;

  String get title => _title ?? "";

  String get artist => _artist ?? "";

  String get album => _album ?? "";

  String get picture => _picture ?? "";

  String get filesize => _filesize ?? "";

  String get sourcepath => _sourcepath ?? "";

  String get extra => _extra ?? "";

  int get updatetime => _updatetime ?? 0;

  int get id => _id ?? 0;

  static String TYPE_FOLD = 'fold';
  static String TYPE_MP3 = 'mp3';
  static String TYPE_FLAC = 'flac';
  static String TYPE_WAV = 'wav';

  MusicInfoModel({
    id: 0,
    name: "",
    path: "",
    fullpath: "",
    type: "",
    syncstatus: false,
    title: "",
    artist: "",
    picture: "",
    album: "",
    sort: 0,
    filesize: "",
    sourcepath: "",
    extra: "",
    updatetime: 0,
  }) {
    this._id = id;
    this._name = name;
    this._path = path;
    this._fullpath = fullpath;
    this._type = type;
    this._syncstatus = syncstatus;
    this._title = title;
    this._artist = artist;
    this._picture = picture;
    this._album = album;
    this._sort = sort;
    this._filesize = filesize;
    this._sourcepath = sourcepath;
    this._extra = extra;
    this._updatetime = updatetime;
  }

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
        picture: json["picture"],
        album: json["album"],
        sort: json["sort"],
        filesize: json["filesize"],
        sourcepath: json["sourcepath"],
        extra: json["extra"],
        updatetime: json["updatetime"],
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
        "picture ": picture,
        "album": album,
        "sort": sort,
        "filesize": filesize,
        "sourcepath": sourcepath,
        "extra": extra,
        "updatetime": updatetime,
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
    map["picture"] = this.picture;
    map["album"] = this.album;
    map["sort"] = this.sort;
    map["filesize"] = this.filesize;
    map["sourcepath"] = this.sourcepath;
    map["extra"] = this.extra;
    map["updatetime"] = this.updatetime;
    return map;
  }

  static MusicInfoModel fromJson(String str) {
    final jsonData = json.decode(str);
    return MusicInfoModel.fromMap(jsonData);
  }

  set name(String value) {
    _name = value;
  }

  set path(String value) {
    _path = value;
  }

  set fullpath(String value) {
    _fullpath = value;
  }

  set type(String value) {
    _type = value;
  }

  set sort(int value) {
    _sort = value;
  }

  set syncstatus(bool value) {
    _syncstatus = value;
  }

  set title(String value) {
    _title = value;
  }

  set artist(String value) {
    _artist = value;
  }

  set album(String value) {
    _album = value;
  }

  set picture(String value) {
    _picture = value;
  }

  set filesize(String value) {
    _filesize = value;
  }

  set sourcepath(String value) {
    _sourcepath = value;
  }

  set extra(String value) {
    _extra = value;
  }

  set updatetime(int value) {
    _updatetime = value;
  }
}
