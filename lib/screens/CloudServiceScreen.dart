import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hello_world/screens/MyHttpServer.dart';
import 'package:hello_world/screens/cloudservice/NextCloudFileScreen.dart';

class CloudServiceScreen extends StatelessWidget {
  CloudServiceScreen();

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Scaffold(
      backgroundColor: themeData.backgroundColor,
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
                  'NextCloud3',
                  style: themeData.textTheme.title,
                ),
                subtitle: Text(
                  '',
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
                onTap: () async {
                  Navigator.of(context, rootNavigator: true)
                      .push(CupertinoPageRoute<void>(
                    title: "Nextcloud",
                    builder: (BuildContext context) => NextCloudFileScreen(
                      title: "Nextcloud",
                      path: "/",
                    ),
                  ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
