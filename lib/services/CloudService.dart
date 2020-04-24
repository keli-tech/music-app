import 'dart:io';

import 'package:dart_tags/dart_tags.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/models/MusicPlayListModel.dart';
import 'package:hello_world/services/Database.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:mime/mime.dart';
import 'package:nextcloud/nextcloud.dart';

class CloudService {
  CloudService._();

  static final CloudService nextCloudClientc = CloudService._();

  NextCloudClient _ncClient;

  Future<NextCloudClient> get ncClient async {
    if (_ncClient != null) return _ncClient;
    // if _database is null we instantiate it

    _ncClient = NextCloudClient('192.168.31.28', 'fence', 'ekstox', port: 801);
    return _ncClient;
  }

  //返回文件列表
  Future<List<WebDavFile>> list(String path) async {
    final client = await ncClient;

    return client.webDav.ls(path).then((files) {
      files.removeWhere((WebDavFile f) =>
          !f.isDirectory &&
          ![
            'audio/mpeg',
            'audio/flac',
            'audio/x-flac',
            'audio/wav',
          ].contains(f.mimeType));

      return files;
    });
  }

  // 下载文件
  Future<bool> download(WebDavFile webDavFile) async {
    final client = await ncClient;

    bool res = true;
    await client.webDav.download(webDavFile.path).then((data) async {
      var file = await FileManager.localCloudFile("nextcloud", webDavFile.name);
      await file.writeAsBytes(data, mode: FileMode.WRITE).then((_) async {
        MusicInfoModel musicInfoModel = await analyseMusicFile(file);
        musicInfoModel.name = webDavFile.name;
        musicInfoModel.path = "/nextcloud/";
        musicInfoModel.fullpath = "/nextcloud/" + musicInfoModel.name;
        musicInfoModel.sourcepath = webDavFile.path;
        musicInfoModel.updatetime = new DateTime.now().millisecondsSinceEpoch;

        int newMid = await DBProvider.db.newMusicInfo(musicInfoModel);
//        ToastUtils.show(musicInfoModel.name + "已下载完成");

        // 添加到专辑表
        MusicPlayListModel newMusicPlayListModel = MusicPlayListModel(
          name: musicInfoModel.album,
          type: MusicPlayListModel.TYPE_ALBUM,
          artist: musicInfoModel.artist,
          sort: 100,
        );
        int newPlid =
            await DBProvider.db.newMusicPlayList(newMusicPlayListModel);
        if (newPlid > 0 && newMid > 0) {
          // 保存到列表
          await DBProvider.db.addMusicToPlayList(newPlid, newMid);
        }
      });
    }).catchError((onError) {
      res = false;
    });

    return res;
  }

  // 分析文件
  Future<MusicInfoModel> analyseMusicFile(File file) async {
    var mimeTypes = {
      "audio/x-flac": "flac",
      "audio/flac": "flac",
      "audio/mpeg": "mp3",
      "audio/wav": "wav",
    };

    String fileSize = Uri.decodeComponent(
        (file.lengthSync() / 1024 / 1024).toStringAsFixed(2).toString() + "MB");

    String artist = "";
    String title = "";
    String album = "";
    AttachedPicture picture;
    int trackID = 0;
    String mimeType = mimeTypes[lookupMimeType(file.path)];

    TagProcessor tp = new TagProcessor();
    await tp.getTagsFromByteArray(file.readAsBytes()).then((tags) async {
      await tags.forEach((tagInfo) async {
        if (tagInfo.tags != null) {
          artist = tagInfo.tags["artist"] ?? "";
          title = tagInfo.tags["title"] ?? "";
          album = tagInfo.tags["album"] ?? "";
          if (tagInfo.tags.containsKey("picture")) {
            picture = tagInfo.tags["picture"];
          }
          trackID = tagInfo.tags.containsKey("track")
              ? int.parse(tagInfo.tags["track"].toString())
              : 0;
        }
      });
    });

    var dir = await FileManager.musicAlbumPicturePath(artist, album)
        .createSync(recursive: true);

    var imageFile = await FileManager.musicAlbumPictureFile(artist, album);
    imageFile
        .writeAsBytes(picture.imageData, mode: FileMode.WRITE)
        .then((_) async {});

//    print(trackID);
    MusicInfoModel newMusicInfo = MusicInfoModel(
        name: title + "." + mimeType,
        title: title,
        path: "",
        fullpath: "",
        artist: artist,
        album: album,
        type: mimeType,
        sort: 1000,
        filesize: fileSize,
        syncstatus: true);

    return newMusicInfo;
  }
}
