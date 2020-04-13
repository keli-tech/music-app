import 'dart:io';

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
    final path = Global.profile.documentDirectory;

    return Directory('$path/picture/$artist/');
  }

  static File musicAlbumPictureFile(String artist, String album) {
    final path = Global.profile.documentDirectory;

    return File('$path/picture/$artist/$album.bmp');
  }

  static ImageProvider musicAlbumPictureImage(String artist, String album) {
    File file = localFile('picture/$artist/$album.bmp');

    return file.existsSync()
        ? FileImage(file)
        : NetworkImage(
            'http://p2.music.126.net/VA3kAvrg2YRrxCgDMJzHnw==/3265549618941178.jpg');
  }
}
