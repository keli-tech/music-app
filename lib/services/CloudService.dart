import 'dart:io';

import 'package:dart_tags/dart_tags.dart';
import 'package:hello_world/models/CloudServiceModel.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/models/MusicPlayListModel.dart';
import 'package:hello_world/services/Database.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:hello_world/utils/webdav/client.dart';
import 'package:hello_world/utils/webdav/file.dart';
import 'package:mime/mime.dart';

class CloudService {
  CloudService._();

  static final CloudService cs = CloudService._();

  WebDavClient _ncClient;

  static String getRootPath(CloudServiceModel cloudServiceModel, String host) {
    if (cloudServiceModel.name.toLowerCase() == "nextcloud") {
      return "/remote.php/webdav/";
    } else {
//      var a = Uri.parse(host);
//      var paths = a.pathSegments;
//      var patharr= paths.getRange(0, paths.length).toList();
//
//      patharr.removeWhere((value) => value == null || value == '');
//
//       paths.join("/");
      return "/";
    }
  }

  static Future<bool> testWebDavClient(CloudServiceModel cloudServiceModel,
      String host, String account, String password) async {
    var a = Uri.parse(host);
    String _rootPath = getRootPath(cloudServiceModel, host);

    var ncClient = WebDavClient(
      host: a.host,
      rootPath: _rootPath,
      scheme: a.scheme,
      port: a.port,
      username: account,
      password: password,
    );
    String indexPath = "/";
    if (cloudServiceModel.name.toLowerCase() == '坚果云') {
      indexPath = "dav";
    }

    try {
      var res = await ncClient.ls(indexPath);
    } catch (error) {
      print(error);
      return false;
    }
    return true;
  }

  initWebDavClient(CloudServiceModel cloudServiceModel) {
    var a = Uri.parse(cloudServiceModel.url);

    _ncClient = WebDavClient(
      host: cloudServiceModel.host,
      scheme: a.scheme,
      rootPath: getRootPath(cloudServiceModel, cloudServiceModel.url),
      username: cloudServiceModel.account,
      password: cloudServiceModel.password,
      port: int.parse(cloudServiceModel.port),
    );
  }

  Future<WebDavClient> get ncClient async {
    return _ncClient;
  }

  //返回文件列表
  Future<List<WebDavFile>> list(String path) async {
    final client = await ncClient;

    return client.ls(path).then((files) {
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
  Future<bool> download(String filePath, WebDavFile webDavFile) async {
    final client = await ncClient;

    bool res = true;
    await client.download(webDavFile.path).then((data) async {
      var file = await FileManager.localCloudFile(filePath, webDavFile.name);

      await file.writeAsBytes(data, mode: FileMode.WRITE).then((_) async {
        MusicInfoModel musicInfoModel = await analyseMusicFile(file);
        musicInfoModel.name = webDavFile.name;
        musicInfoModel.path = filePath;
        musicInfoModel.fullpath = filePath + musicInfoModel.name;
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

  //根据播放列表
  Future<List<CloudServiceModel>> getCloudServiceList() async {
    final db = await DBProvider.db.database;

    List<CloudServiceModel> list = [];
    try {
      var res = await db.query("cloud_service",
          orderBy: "updatetime desc, id asc", whereArgs: []);

      list = res.isNotEmpty
          ? res.map((c) => CloudServiceModel.fromMap(c)).toList()
          : [];
    } catch (err) {
      print(err);
    }
    return list;
  }

  //根据播放列表
  Future<int> updateCloudService(int id, Map updateValue) async {
    final db = await DBProvider.db.database;

    var res = await db
        .update("cloud_service", updateValue, where: " id = ?", whereArgs: [
      id,
    ]);

    return res;
  }
}
