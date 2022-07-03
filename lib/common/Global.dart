import 'package:flutter/material.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/Profile.dart';

// 提供五套可选主题色
const _themes = <MaterialColor>[
  Colors.blue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.red,
];

class Global {
  static Profile profile = new Profile(
    id: 0,
    musicInfo: new MusicInfoModel(),
    musicInfoList: [],
    musicInfoFavList: [],
    playIndex: 0,
    documentDirectory: "",
  );

  // 广告开关
  static bool showAd = false;

  // 可选的主题列表
  static List<MaterialColor> get themes => _themes;

  // 是否为release版
  static bool get isRelease => bool.fromEnvironment("dart.vm.product");

  //初始化全局信息，会在APP启动时执行
  static Future init() async {
    var _prefs = await SharedPreferences.getInstance();
    final directory = await getApplicationDocumentsDirectory();

    var _profile = _prefs.getString("profile");
    if (_profile != null) {
      try {
        profile = Profile.fromJson(_profile);
      } catch (e) {
        print(e);
      }
    }

    // 如果没有缓存策略，设置默认缓存策略
    if (profile.musicInfo.id <= 0) {
      profile.musicInfo = MusicInfoModel()
        ..id = 0
        ..name = ""
        ..path = ""
        ..fullpath = ""
        ..type = ""
        ..syncstatus = true;
    }

    // 如果没有缓存策略，设置默认缓存策略
    if (profile.musicInfoList == null) {
      profile.musicInfoList = [];
    }
    if (profile.playIndex == null) {
      profile.playIndex = 0;
    }

    profile.documentDirectory = directory.path;
    // _logger.info(profile.toJson().toString());
    Logger _logger = new Logger("Global");
    _logger.info("init");
  }

  // 持久化Profile信息
  static saveProfile() async {
    var _prefs = await SharedPreferences.getInstance();
    _prefs.setString("profile", profile.toJson());
  }
}
