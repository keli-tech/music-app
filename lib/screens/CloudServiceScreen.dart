import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hello_world/models/CloudServiceModel.dart';
import 'package:hello_world/screens/MyHttpServer.dart';
import 'package:hello_world/screens/cloudservice/LoginCloudServiceScreen.dart';
import 'package:hello_world/screens/cloudservice/NextCloudFileScreen.dart';
import 'package:hello_world/services/CloudService.dart';
import 'package:url_launcher/url_launcher.dart';

class CloudServiceScreen extends StatefulWidget {
  @override
  _CloudServiceScreen createState() => _CloudServiceScreen();
}

class _CloudServiceScreen extends State<CloudServiceScreen> {
  List<CloudServiceModel> _cloudServiceModels = [];

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  @override
  void deactivate() {
    super.deactivate();
    _refreshList();
  }

  _refreshList() {
    try {
      CloudService.cs.getCloudServiceList().then((onValue) {
        setState(() {
          _cloudServiceModels = onValue;
        });
      });
    } catch (err) {
      print(err);
    }
  }

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
                ),
              ),
              new ListTile(
                title: new Text(
                  'Wi-Fi同步文件',
                ),
                subtitle: Text(
                  '手机与电脑连接到同一个Wi-Fi网络，可以通过电脑端web浏览器来传输文件。',
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
                ),
              ),
              Column(
                children: buildService(),
              ),
              new Divider(),
              new ListTile(
                title: new Text(
                  '帮助文档',
                ),
                leading: new Icon(
                  Icons.help,
                  size: 34,
                  color: themeData.primaryColor,
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: themeData.primaryColor,
                ),
                onTap: () async {
                  const url = 'https://keli.tech/music/help';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    print('Could not launch $url');
                  }
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildService() {
    var res = _cloudServiceModels.map((item) {
      return new ListTile(
        title: new Text(
          item.name,
        ),
        subtitle: Text(
          item.signedin ? '已连接:' + item.url : '请登录',
          maxLines: 1,
        ),
        leading: new Image.asset(
          item.assetspath,
          width: 30,
        ),
        trailing: Icon(
          Icons.chevron_right,
        ),
        onTap: () async {
          if (item.signedin) {
            String indexPath = "/";
            if (item.name.toLowerCase() == '坚果云') {
              indexPath = "dav";
            }

            Navigator.of(context).push(CupertinoPageRoute<void>(
              title: item.name,
              builder: (BuildContext context) => NextCloudFileScreen(
                title: item.name,
                path: indexPath,
                filePath: "/${item.name.toLowerCase()}/",
                cloudServiceModel: item,
              ),
            ));
          } else {
            Navigator.of(context).push(CupertinoPageRoute<void>(
              title: item.name,
              builder: (BuildContext context) => LoginCloudServiceScreen(
                title: item.name,
                cloudServiceModel: item,
              ),
            ));
          }
        },
      );
    }).toList();

    return res;
  }
}
