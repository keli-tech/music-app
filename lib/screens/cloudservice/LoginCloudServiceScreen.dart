import 'dart:io';

// import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/common/Global.dart';
import 'package:hello_world/components/Tile.dart';
import 'package:hello_world/models/CloudServiceModel.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/screens/cloudservice/NextCloudFileScreen.dart';
// import 'package:hello_world/services/AdmobService.dart3';
import 'package:hello_world/services/CloudService.dart';
import 'package:hello_world/services/Database.dart';
import 'package:hello_world/services/FileManager.dart';
import 'package:hello_world/utils/ToastUtils.dart';
import 'package:hello_world/utils/webdav/file.dart';

class LoginCloudServiceScreen extends StatefulWidget {
  LoginCloudServiceScreen(
      {Key key,
      this.musicInfoModel,
      this.path,
      this.title,
      this.cloudServiceModel})
      : super(key: key);

  static const String routeName = '/filelist2';
  static const String className = "LoginCloudServiceScreen";

  String path = "/";
  String title = "";
  CloudServiceModel cloudServiceModel;

  MusicInfoModel musicInfoModel;

  @override
  _LoginCloudServiceScreen createState() => _LoginCloudServiceScreen();
}

class _LoginCloudServiceScreen extends State<LoginCloudServiceScreen>
    with SingleTickerProviderStateMixin {
  List<WebDavFile> _files = [];
  Animation<double> animation;
  List<String> _downloadedFiles;
  TextEditingController _urlTextController;
  TextEditingController _accountTextController;
  TextEditingController _passwordTextController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _urlTextController =
        TextEditingController(text: widget.cloudServiceModel.url);
    _accountTextController =
        TextEditingController(text: widget.cloudServiceModel.account);
    _passwordTextController =
        TextEditingController(text: widget.cloudServiceModel.password);
  }

  //销毁
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return CupertinoPageScaffold(
        backgroundColor: themeData.backgroundColor,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: themeData.backgroundColor,
          middle: Text(
            widget.title,
            style: themeData.primaryTextTheme.headline6,
          ),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: Column(
            children: <Widget>[
              Global.showAd
                  ? Container(
                      // child: AdmobBanner(
                      //   adUnitId: AdMobService.getBannerAdUnitId(
                      //       LoginCloudServiceScreen.className),
                      //   adSize: AdmobBannerSize.FULL_BANNER,
                      //   listener:
                      //       (AdmobAdEvent event, Map<String, dynamic> args) {
                      //     AdMobService.handleEvent(event, args, 'Banner');
                      //   },
                      // ),
                    )
                  : Container(),
              SizedBox(
                height: 20,
              ),
              CupertinoTextField(
                controller: _urlTextController,
                prefix: const Icon(
                  Icons.http,
                  color: CupertinoColors.lightBackgroundGray,
                  size: 28.0,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 6.0, vertical: 12.0),
                clearButtonMode: OverlayVisibilityMode.editing,
                textCapitalization: TextCapitalization.words,
                decoration: const BoxDecoration(
                  border: Border(
                      bottom:
                          BorderSide(width: 0.0, color: CupertinoColors.white)),
                ),
                placeholder: 'http://192.168.10.100:8081/',
              ),
              CupertinoTextField(
                controller: _accountTextController,
                prefix: const Icon(
                  CupertinoIcons.person_solid,
                  color: CupertinoColors.lightBackgroundGray,
                  size: 28.0,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 6.0, vertical: 12.0),
                clearButtonMode: OverlayVisibilityMode.editing,
                textCapitalization: TextCapitalization.words,
                decoration: const BoxDecoration(
                  border: Border(
                      bottom:
                          BorderSide(width: 0.0, color: CupertinoColors.white)),
                ),
                placeholder: '用户名',
              ),
              CupertinoTextField(
                controller: _passwordTextController,
                prefix: const Icon(
                  Icons.title,
                  color: CupertinoColors.lightBackgroundGray,
                  size: 28.0,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 6.0, vertical: 12.0),
                clearButtonMode: OverlayVisibilityMode.editing,
                textCapitalization: TextCapitalization.words,
                decoration: const BoxDecoration(
                  border: Border(
                      bottom:
                          BorderSide(width: 0.0, color: CupertinoColors.white)),
                ),
                placeholder: '密码',
              ),
              SizedBox(
                height: 20,
              ),
              Tile(
                selected: false,
                radiusnum: 5,
                child: RaisedButton(
                  padding:
                      EdgeInsets.only(left: 30, top: 15, right: 30, bottom: 15),
                  color: themeData.primaryColorDark,
                  child: Text("连接", style: TextStyle(
                    color: themeData.primaryColorLight,
                  )),
                  onPressed: () {
                    String host = _urlTextController.text.trim();
                    String account = _accountTextController.text.trim();
                    String password = _passwordTextController.text.trim();

                    var uri = Uri.parse(host);
                    CloudService.testWebDavClient(
                            widget.cloudServiceModel, host, account, password)
                        .then((connected) async {
                      if (connected) {
                        // 1. 保存账号密码
                        // 2. 跳转到已登录的页面
                        String indexPath = "/";
                        if (widget.cloudServiceModel.name.toLowerCase() ==
                            '坚果云') {
                          indexPath = "dav";
                        }

                        var updateValue = {
                          "account": account,
                          "password": password,
                          "host": uri.host,
                          "port": uri.port.toString(),
                          "url": host,
                          "signedin": true,
                          "updatetime":
                              new DateTime.now().millisecondsSinceEpoch,
                        };

                        final localpath =
                            FileManager.localPathDirectory();
                        var dir = await new Directory(localpath +
                                widget.cloudServiceModel.name.toLowerCase() +
                                "/")
                            .create(recursive: true);

                        MusicInfoModel newMusicInfo = MusicInfoModel(
                            name: widget.cloudServiceModel.name.toLowerCase(),
                            path: "/",
                            fullpath: "/" +
                                widget.cloudServiceModel.name.toLowerCase() +
                                "/",
                            type: MusicInfoModel.TYPE_FOLD,
                            sort: 1,
                            updatetime:
                                new DateTime.now().millisecondsSinceEpoch,
                            syncstatus: true);

                        var res =
                            await DBProvider.db.newMusicInfo(newMusicInfo);

                        CloudService.cs
                            .updateCloudService(
                                widget.cloudServiceModel.id, updateValue)
                            .then((res) {
                          if (res > 0) {
                            ToastUtils.show("连接成功, 账号密码已保存！");
                          }
                        });

                        CloudServiceModel newCloudServiceModel =
                            CloudServiceModel.fromJson(
                                widget.cloudServiceModel.toJson());

                        var uri2 = Uri.parse(host);
                        newCloudServiceModel.host = uri2.host;
                        newCloudServiceModel.url = host;
                        newCloudServiceModel.host = uri2.host;
                        newCloudServiceModel.port = uri2.port.toString();
                        newCloudServiceModel.account = account;
                        newCloudServiceModel.password = password;
                        newCloudServiceModel.signedin = true;
                        newCloudServiceModel.updatetime =
                            new DateTime.now().millisecondsSinceEpoch;

                        Navigator.of(context).pushReplacement(
                            CupertinoPageRoute<void>(
                                builder: (BuildContext context) =>
                                    NextCloudFileScreen(
                                      title: uri.host,
                                      path: indexPath,
                                      filePath:
                                          "/${widget.cloudServiceModel.name.toLowerCase()}/",
                                      cloudServiceModel: newCloudServiceModel,
                                    )));
                      } else {
                        ToastUtils.show("连接失败，请检查网络和账号密码！");
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
