import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hello_world/components/Tile.dart';
import 'package:hello_world/models/CloudServiceModel.dart';
import 'package:hello_world/screens/album/AlbumListScreen.dart';
import 'package:hello_world/screens/album/ArtistListScreen.dart';
import 'package:hello_world/services/CloudService.dart';

class TypeScreen extends StatefulWidget {
  @override
  _TypeScreen createState() => _TypeScreen();
}

class _TypeScreen extends State<TypeScreen> {
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
                                  title: new Text('专辑',
                                      style: themeData.primaryTextTheme.headline6),
                                  leading: new Icon(Icons.album,
                                      size: 40, color: themeData.primaryColor),
                                  trailing: Icon(Icons.chevron_right,
                                      color: themeData.primaryColor),
                                  onTap: () async {
                                    Navigator.of(context)
                                        .push(CupertinoPageRoute<void>(
                                      builder: (BuildContext context) =>
                                          AlbumListScreen(),
                                    ));
                                  }),
                            ),
                            Tile(
                              selected: false,
                              radiusnum: 15.0,
                              child: new ListTile(
                                  title: new Text('歌手',
                                      style: themeData.primaryTextTheme.headline6),
                                  leading: new Icon(Icons.person_pin,
                                      size: 40, color: themeData.primaryColor),
                                  trailing: Icon(Icons.chevron_right,
                                      color: themeData.primaryColor),
                                  onTap: () async {
                                    Navigator.of(context)
                                        .push(CupertinoPageRoute<void>(
                                      builder: (BuildContext context) =>
                                          ArtistListScreen(),
                                    ));
                                  }),
                            ),
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
}
