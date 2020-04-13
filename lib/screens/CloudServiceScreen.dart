import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hello_world/screens/MyHttpServer.dart';
import 'package:provider/provider.dart';

import '../models/MusicInfoModel.dart';
import '../services/Database.dart';
import '../services/EventBus.dart';

class CloudServiceScreen extends StatefulWidget {
  @override
  _CloudServiceScreen createState() => _CloudServiceScreen();
}

class _CloudServiceScreen extends State<CloudServiceScreen>
    with SingleTickerProviderStateMixin {
  List<MusicInfoModel> _musicInfoModels = [];
  TextEditingController _chatTextController = TextEditingController();
  Animation<double> animation;
  AnimationController controller;

  var _eventBusOn;

  @override
  void initState() {
    super.initState();

    _refreshList();

    controller = new AnimationController(
        duration: const Duration(seconds: 10), vsync: this);
    //图片宽高从0变到300
    animation = new Tween(begin: 0.0, end: 720.0).animate(controller);
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        //动画执行结束时反向执行动画
        controller.reset();

        controller.forward();
      } else if (status == AnimationStatus.dismissed) {
        //动画恢复到初始状态时执行动画（正向）
        controller.forward();
      }
    });

    //启动动画（正向）
    controller.stop();

    _eventBusOn = eventBus.on<MusicPlayEvent>().listen((event) {
      if (event.musicPlayAction == MusicPlayAction.play) {
        controller.forward();
      } else if (event.musicPlayAction == MusicPlayAction.stop) {
        controller.stop();
      }
      setState(() {});
    });
  }

  //销毁
  @override
  void dispose() {
    this._eventBusOn.cancel();

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

    var dataInfo = Provider.of<MusicInfoData>(context, listen: false);

    return Scaffold(
      backgroundColor: themeData.backgroundColor,
      appBar: CupertinoNavigationBar(
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
                onTap: (){
                  Navigator.of(context).push(CupertinoPageRoute<void>(
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
    );
  }
}
