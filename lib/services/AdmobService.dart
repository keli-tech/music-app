import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:hello_world/screens/AlbumListScreen.dart';
import 'package:hello_world/screens/FileListScreen.dart';
import 'package:hello_world/screens/MyHttpServer.dart';
import 'package:hello_world/screens/cloudservice/LoginCloudServiceScreen.dart';
import 'package:hello_world/screens/cloudservice/NextCloudFileScreen.dart';
import 'package:hello_world/utils/ToastUtils.dart';

class AdMobService {
  static String getBannerAdUnitId(String screen) {
    String adUnitId = null;
    if (Platform.isIOS) {
      // 测试
//      return 'ca-app-pub-3940256099942544/2934735716';
//    广告格式	示例广告单元 ID
//    横幅广告	ca-app-pub-3940256099942544/2934735716
//    插页式广告	ca-app-pub-3940256099942544/4411468910
//    插页式视频广告	ca-app-pub-3940256099942544/5135589807
//    激励视频广告	ca-app-pub-3940256099942544/1712485313
//    原生高级广告	ca-app-pub-3940256099942544/3986624511
//    原生高级视频广告	ca-app-pub-3940256099942544/2521693316

      switch (screen) {
        case FileListScreen.className:
          // 专辑列表横幅
          adUnitId = 'ca-app-pub-8997196463219106/9799847403';
          break;
        case AlbumListScreen.className:
          // 云同步界面横幅
          adUnitId = 'ca-app-pub-8997196463219106/7074924792';
          break;
        case MyHttpServer.className:
          // WiFi Driver 横幅
          adUnitId = 'ca-app-pub-8997196463219106/9949974928';
          break;
        case LoginCloudServiceScreen.className:
          // 登录云服务 横幅
          adUnitId = 'ca-app-pub-8997196463219106/5832273117';
          break;
        case NextCloudFileScreen.className:
          // 云服务文件 横幅
          adUnitId = 'ca-app-pub-8997196463219106/7855160592';
          break;
        default:
          // WiFi Driver 横幅
          adUnitId = 'ca-app-pub-8997196463219106/9949974928';
          break;
      }
    } else if (Platform.isAndroid) {
      adUnitId = 'ca-app-pub-3940256099942544/6300978111';
    }
    //print(adUnitId);
    return adUnitId;
  }

  static void handleEvent(
      AdmobAdEvent event, Map<String, dynamic> args, String adType) {
    return;

    switch (event) {
      case AdmobAdEvent.loaded:
        ToastUtils.show('New Admob $adType Ad loaded!');
        break;
      case AdmobAdEvent.opened:
        ToastUtils.show('Admob $adType Ad opened!');
        break;
      case AdmobAdEvent.closed:
        ToastUtils.show('Admob $adType Ad closed!');
        break;
      case AdmobAdEvent.failedToLoad:
        ToastUtils.show('Admob $adType failed to load. :(');
        break;
      case AdmobAdEvent.rewarded:
        break;
      default:
    }
  }
}
