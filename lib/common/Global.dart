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
  static SharedPreferences _prefs;
  static Profile profile = Profile();

  // 可选的主题列表
  static List<MaterialColor> get themes => _themes;

  // 是否为release版
  static bool get isRelease => bool.fromEnvironment("dart.vm.product");

  // 广告开关
  static bool showAd = isRelease;

  //初始化全局信息，会在APP启动时执行
  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
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
    if (profile.musicInfo == null || profile.musicInfo.id <= 0) {
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
    if (profile.playMode == null) {
      profile.playMode = PlayMode.order;
    }
//    print(profile.playMode);

    profile.documentDirectory = directory.path;

    Logger _logger = new Logger("Global");
    _logger.info(profile.toJson().toString());
  }

  // 持久化Profile信息
  static saveProfile() => _prefs.setString("profile", profile.toJson());
}
