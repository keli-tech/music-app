import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hello_world/screens/MyHttpServer.dart';

import '../models/MusicInfoModel.dart';
import '../services/Database.dart';

class CloudServiceScreen extends StatefulWidget {
  @override
  _CloudServiceScreen createState() => _CloudServiceScreen();

  CloudServiceScreen({Key key, this.statusBarHeight}) : super(key: key);

  int statusBarHeight;
}

class _CloudServiceScreen extends State<CloudServiceScreen>
    with SingleTickerProviderStateMixin {
  List<MusicInfoModel> _musicInfoModels = [];

  @override
  void initState() {
    super.initState();

    _refreshList();
  }

  //销毁
  @override
  void dispose() {
    print("play screen disposed!!");
    super.dispose();
  }

  _refreshList() async {
    DBProvider.db.getMusicInfoByPath("/").then((onValue) {
      setState(() {
        _musicInfoModels = onValue;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Container(
      color: themeData.backgroundColor,
      padding: EdgeInsetsDirectional.only(top: 20),
      child: Scaffold(
        backgroundColor: themeData.backgroundColor,
        appBar: CupertinoNavigationBar(
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            pressedOpacity: 1,
            child: Icon(
              Icons.keyboard_arrow_down,
              size: 35,
              semanticLabel: 'Add',
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          middle: Text(
            '云同步',
            style: themeData.primaryTextTheme.headline,
          ),
          backgroundColor: themeData.backgroundColor,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(left: 5, top: 10, right: 5, bottom: 10),
          child: Center(
            child: Column(
              children: <Widget>[
                new ListTile(
                  title: new Text(
                    '云同步',
                    style: themeData.textTheme.subtitle,
                  ),
                ),
                new ListTile(
                  title: new Text(
                    'Wi-Fi同步文件',
                    style: themeData.textTheme.title,
                  ),
                  subtitle: Text(
                    '手机与电脑连接到同一个Wi-Fi网络，可以通过电脑端web浏览器来传输文件。',
                    style: themeData.textTheme.subtitle,
                  ),
                  leading: new Icon(
                    Icons.wifi,
                    color: themeData.primaryColor,
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: themeData.primaryColor,
                  ),
                  onTap: () {
                    Navigator.of(context, rootNavigator: true)
                        .push(CupertinoPageRoute<void>(
                      title: "Wi-Fi同步文件",
                      builder: (BuildContext context) => MyHttpServer(
                          // color: color,
                          // colorName: colorName,
                          // index: index,
                          ),
                    ));
                  },
                ),
                new Divider(),
                new ListTile(
                  title: new Text(
                    '云服务',
                    style: themeData.textTheme.subtitle,
                  ),
                ),
                new ListTile(
                  title: new Text(
                    '百度网盘',
                    style: themeData.textTheme.title,
                  ),
                  leading: new Image.asset(
                    "assets/images/cloudicon/baidu.png",
                    width: 30,
                  ),
                  subtitle: Text(
                    '等待上线',
                    style: themeData.textTheme.subtitle,
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: themeData.primaryColor,
                  ),
                ),
                new ListTile(
                  title: new Text(
                    'OneDrive',
                    style: themeData.textTheme.title,
                  ),
                  subtitle: Text(
                    '等待上线',
                    style: themeData.textTheme.subtitle,
                  ),
                  leading: new Image.asset(
                    "assets/images/cloudicon/onedrive.png",
                    width: 30,
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: themeData.primaryColor,
                  ),
                ),
                new ListTile(
                  title: new Text(
                    'NextCloud',
                    style: themeData.textTheme.title,
                  ),
                  subtitle: Text(
                    '等待上线',
                    style: themeData.textTheme.subtitle,
                  ),
                  leading: new Image.asset(
                    "assets/images/cloudicon/nextcloud.png",
                    width: 30,
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: themeData.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
