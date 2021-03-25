import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hello_world/components/Tile.dart';
import 'package:hello_world/models/CloudServiceModel.dart';
import 'package:hello_world/screens/cloudservice/LoginCloudServiceScreen.dart';
import 'package:hello_world/screens/cloudservice/MyHttpServer.dart';
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

    return CupertinoPageScaffold(
      backgroundColor: themeData.backgroundColor,
      child: Scrollbar(
        child: CustomScrollView(
          slivers: <Widget>[
            CupertinoSliverNavigationBar(
              //actionsForegroundColor: themeData.primaryColorDark,
              backgroundColor: themeData.primaryColorLight,
              border: null,
              automaticallyImplyTitle: false,
              automaticallyImplyLeading: false,
              largeTitle: Text(
                "云同步",
                style: TextStyle(
                  color: themeData.primaryColorDark,
                ),
              ),
            ),
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Material(
                      color: themeData.backgroundColor,
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 10),
                            Tile(
                              selected: false,
                              radiusnum: 15.0,
                              child: new ListTile(
                                title: new Text(
                                  'Wi-Fi同步文件',
                                  style: themeData.primaryTextTheme.title,
                                ),
                                subtitle: Text(
                                  '手机与电脑连接到同一个Wi-Fi网络，可以通过电脑端web浏览器来传输文件。',
                                  style: themeData.primaryTextTheme.subtitle,
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
                                    builder: (BuildContext context) =>
                                        MyHttpServer(
                                            // color: color,
                                            // colorName: colorName,
                                            // index: index,
                                            ),
                                  ));
                                },
                              ),
                            ),
                            ListTile(
                              title: new Text(
                                '云服务',
                                style: themeData.primaryTextTheme.title,
                              ),
                            ),
                            Column(
                              children: buildService(context),
                            ),
                            new Divider(),
                            Tile(
                              selected: false,
                              radiusnum: 15.0,
                              child: new ListTile(
                                title: new Text(
                                  '帮助文档',
                                  style: themeData.primaryTextTheme.title,
                                ),
                                leading: new Icon(
                                  Icons.help,
                                  size: 40,
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
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildService(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    var res = _cloudServiceModels.map((item) {
      return Tile(
        selected: false,
        radiusnum: 15.0,
        child: ListTile(
          title: new Text(
            item.name,
            style: themeData.primaryTextTheme.title,
          ),
          subtitle: Text(
            item.signedin ? '已连接:' + item.url : '请登录',
            style: themeData.primaryTextTheme.subtitle,
            maxLines: 1,
          ),
          leading: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              color: Colors.black45,
            ),
            child: Image.asset(
              item.assetspath,
              width: 40,
            ),
          ),
          trailing: Tile(
            selected: false,
            radiusnum: 20,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: themeData.primaryColorDark,
              foregroundColor: themeData.primaryColorLight,
              child: Icon(
                Icons.arrow_forward,
                size: 18,
              ),
            ),
          ),
          onTap: () async {
            if (item.signedin) {
              String indexPath = "/";
              if (item.name.toLowerCase() == '坚果云') {
                indexPath = "dav";
              }

              Navigator.of(
                context,
              ).push(CupertinoPageRoute<void>(
                title: item.name,
                builder: (BuildContext context) => NextCloudFileScreen(
                  title: item.name,
                  path: indexPath,
                  filePath: "/${item.name.toLowerCase()}/",
                  cloudServiceModel: item,
                ),
              ));
            } else {
              Navigator.of(
                context,
              ).push(CupertinoPageRoute<void>(
                title: item.name,
                builder: (BuildContext context) => LoginCloudServiceScreen(
                  title: item.name,
                  cloudServiceModel: item,
                ),
              ));
            }
          },
        ),
      );
    }).toList();

    return res;
  }
}
