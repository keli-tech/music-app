import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:hello_world/common/Global.dart';
import 'package:hello_world/models/MusicPlayListModel.dart';
import 'package:image/image.dart' as i;
import 'package:logging/logging.dart';
import 'package:mime/mime.dart';
import '../../models/MusicInfoModel.dart';
import 'package:dart_tags/dart_tags.dart';

import 'Database.dart';

class FileManager {
  static Logger _logger = new Logger("FileManager");

  // service = '/nextcloud/' 带 前后缀
  static File localCloudFile(String service, String fileName) {
    final path = Global.profile.documentDirectory;

    Directory('$path$service').createSync(recursive: true);

    return File('$path$service$fileName');
  }

  static File localFile(String fileName) {
    final path = Global.profile.documentDirectory;

//    _logger.info('$path$fileName');
    try {
      var file = File('$path$fileName');
      return file;
    } catch (error) {
      return File(path);
    }
  }

  static String localPathDirectory() {
    final path = Global.profile.documentDirectory;

    return '$path/';
  }

  static String musicFilePath(String? fullpath) {
    if (fullpath == null) {
      return "";
    }
    final path = Global.profile.documentDirectory;

    return '$path/' + fullpath;
  }

  static File musicFile(String fullpath) {
    final path = Global.profile.documentDirectory;

    var file = ('$path/' + fullpath);
    return File(file);
  }

  // 专辑歌手目录-绝对路径
  static Directory musicAlbumPicturePath(String artist) {
    final path = Global.profile.documentDirectory;

    return Directory('$path/picture/$artist/');
  }

  // 专辑封面文件路径-绝对路径
  static Directory musicAlbumPictureFullPath(String artist, String album) {
    album = md5.convert(utf8.encode(album)).toString();
    final path = Global.profile.documentDirectory;
    musicAlbumPicturePath(artist).createSync(recursive: true);

    return Directory('$path/picture/$artist/$album.bmp');
  }

  // 新插入的专辑图片 String
  static String newMusicAlbumPicturePathRelative(String artist, String album) {
    album = md5.convert(utf8.encode(album)).toString();

    return '/picture/$artist/$album.jpg';
  }

  // 新插入的专辑图片 File
  static File newMusicAlbumPictureFile(String artist, String album) {
    final path = Global.profile.documentDirectory;
    String relaPath = newMusicAlbumPicturePathRelative(artist, album);

    return File('$path$relaPath');
  }

  static File musicAlbumPictureFile(String artist, String album) {
    final path = Global.profile.documentDirectory;
    album = md5.convert(utf8.encode(album)).toString();

    return File('$path/picture/$artist/$album.jpg');
  }

  static ImageProvider musicAlbumPictureImage(String artist, String album) {
    String mimeType = "jpg";
    album = md5.convert(utf8.encode(album)).toString();
    File file = localFile('/picture/$artist/$album.$mimeType');

    return (file.existsSync()
        ? FileImage(file)
        : AssetImage('assets/images/logo.png')) as ImageProvider;
  }

  // === NEXTCLOUD ===
  static String getNextcloudPath(String fullpath) {
    final path = Global.profile.documentDirectory;

    return '$path/' + fullpath;
  }

  static void saveAudioFileInfo(
      File file, String musicPath, String title) async {
    int fileLength = await file.length();
    String fileSize = Uri.decodeComponent(
        (fileLength / 1024 / 1024).toStringAsFixed(2).toString() + "MB");

    var fileType = title.split(".").last.toLowerCase();

    // 保存到数据库
    // todo bugfix, 部分无tab mp3 未读取到 tag，会卡住, 比如flac
    TagProcessor tp = new TagProcessor();

    AttachedPicture? picture;
    String artist = "未知";
    String album = "未知";

    // runZoned 捕获异步异常
    var runZoned2 = await runZoned(() async {
      var l = await tp.getTagsFromByteArray(file.readAsBytes());

      l.forEach((f) {
        if (f.tags != null && f.tags.containsKey("picture")) {
          _logger.info(f.tags["picture"]);
          //
          // 保存音乐文件表
          var pictureTmp = (f.tags['picture'] as Map).values.first;
          if (pictureTmp.imageTypeCode != 0) {
            picture = pictureTmp;
          }

          _logger.info(picture);

          title = f.tags["title"];
          artist = f.tags["artist"];
          album = f.tags["album"];
        }
      });
    }, onError: (Object obj, StackTrace stack) {
      print(obj);
      print(stack);
    });

    var mimeTypes = {
      "image/jpg": "jpg",
      "image/jpeg": "jpg",
    };
    String mimeType = "bmp";
    if (picture != null && picture?.mime != null) {
      var mimeTypeTmp = mimeTypes[picture!.mime];
      if (mimeTypeTmp != null) {
        mimeType = mimeTypeTmp;
      }
    }

    MusicInfoModel newMusicInfo = MusicInfoModel(
      name: title,
      path: musicPath,
      fullpath: musicPath + file.path.split("/").last,
      type: fileType,
      syncstatus: true,
      title: title,
      artist: artist,
      picture: "",
      filesize: fileSize,
      album: album,
      sort: 100,
      updatetime: new DateTime.now().millisecondsSinceEpoch,
    );
    _logger.info(newMusicInfo);
    int newMid = await DBProvider.db.newMusicInfo(newMusicInfo);

    String picturePath = "";
    // 保存音乐封面
    if (picture != null && picture?.imageData != null) {
      // 创建歌手目录
      await musicAlbumPicturePath(artist).create(recursive: true);
      var imageFile = newMusicAlbumPictureFile(artist, album);
      picturePath = newMusicAlbumPicturePathRelative(artist, album);

      i.Image? image;
      switch (mimeType) {
        case "jpg":
          image = i.decodeJpg(picture!.imageData);
          break;
        case "bmp":
          image = i.decodeBmp(picture!.imageData);
          break;
      }

      if (image != null) {
        // 默认存储为 jpg
        imageFile.writeAsBytesSync(i.encodeJpg(image), mode: FileMode.write);
      }
    }

    // 添加到专辑表
    MusicPlayListModel newMusicPlayListModel = MusicPlayListModel(
      name: album,
      type: MusicPlayListModel.TYPE_ALBUM,
      artist: artist,
      sort: 100,
      imgpath: picturePath,
    );
    _logger.info(newMusicPlayListModel);
    int newPlid = await DBProvider.db.newMusicPlayList(newMusicPlayListModel);
    if (newPlid > 0 && newMid > 0) {
      // 保存到列表
      await DBProvider.db.addMusicToPlayList(newPlid, newMid);
    }
  }

  static void cleanAllFiles() async {
    final path = Global.profile.documentDirectory;

    Directory('$path/').listSync().forEach((file) {
      if (file.path.split(".").last == "db") {
        return;
      }

      file.deleteSync(recursive: true);
    });
    _logger.info("清理成功！");
  }
}
