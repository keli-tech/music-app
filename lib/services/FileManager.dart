import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:hello_world/common/Global.dart';

class FileManager {
  static File localFile(String fileName) {
    final path = Global.profile.documentDirectory;

    return File('$path/$fileName');
  }

  static String musicFilePath(String fullpath) {
    final path = Global.profile.documentDirectory;

    return '${path}/' + fullpath;
  }

  static File musicFile(String fullpath) {
    final path = Global.profile.documentDirectory;

    var file = ('${path}/' + fullpath);
    return File(file);
  }

  static Directory musicAlbumPicturePath(String artist, String album) {
    album = md5.convert(utf8.encode(album)).toString();

    final path = Global.profile.documentDirectory;

    return Directory('$path/picture/$artist/');
  }

  static Directory musicAlbumPictureFullPath(String artist, String album) {
    album = md5.convert(utf8.encode(album)).toString();
    final path = Global.profile.documentDirectory;
    musicAlbumPicturePath(artist, album).createSync(recursive: true);

    return Directory('$path/picture/$artist/$album.bmp');
  }

//  ec65e03c35f13e703348c6941c6b3141
  static File musicAlbumPictureFile(String artist, String album) {
    final path = Global.profile.documentDirectory;
    album = md5.convert(utf8.encode(album)).toString();

    return File('$path/picture/$artist/$album.bmp');
  }

  static ImageProvider musicAlbumPictureImage(String artist, String album) {
    if (album == null) {
      album = "";
    }

    if (artist == null) {
      artist = "";
    }

    album = md5.convert(utf8.encode(album)).toString();
    File file = localFile('picture/$artist/$album.bmp');

    return file.existsSync()
        ? FileImage(file)
        : NetworkImage(
            'http://p2.music.126.net/VA3kAvrg2YRrxCgDMJzHnw==/3265549618941178.jpg');
  }
}
