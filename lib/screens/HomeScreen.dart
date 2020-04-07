import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/EventBus.dart';
import '../screens/MusicListScreen.dart';

/**
 * 
 * 列表页
 */

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _ListItem {
  _ListItem(this.value, this.checkState);

  final String value;

  bool checkState;
}

class _HomeScreenState extends State<HomeScreen> {
  final List<_ListItem> _items = <String>[
    'A',
    'B',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
  ].map<_ListItem>((String item) => _ListItem(item, true)).toList();

  @override
  void initState() {
    super.initState();
  }

  Widget buildListTile(_ListItem item) {
    return Container(
      height: 72,
      child: ListTile(
        title: Text('Save Rock And Roll'),
        subtitle: Text('Fall Out Boy'),
        isThreeLine: false,
        leading: ExcludeSemantics(
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              backgroundBlendMode: BlendMode.colorBurn,
              shape: BoxShape.rectangle,
              color: Colors.green,
              // border: Border(
              //   top: BorderSide(width: 2, color: Colors.red),
              //   left: BorderSide(width: 2, color: Colors.red),
              //   right: BorderSide(width: 2, color: Colors.red),
              //   bottom: BorderSide(width: 2, color: Colors.red),
              // ),
              borderRadius: BorderRadius.circular(10.0),
              image: DecorationImage(
                fit: BoxFit.fill, //这个地方很重要，需要设置才能充满
                image: NetworkImage(
                    'http://p1.music.126.net/TYwiMwjbr5dfD0K44n-xww==/109951163409466795.jpg'),
              ),
            ),
          ),
        ),

        // CircleAvatar(child: Text('asdf'))
        // title: new Text('sadf'),
        // trailing: new Icon(Icons.keyboard_arrow_right),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return MusicListScreen(
              title: 'The Phoenix',
            );
          }));
          print('hehe');
        },
        enabled: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    double _statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeData.accentColor,
        //  Color.fromARGB(255, 225, 235, 250),
        title: Text(
          widget.title,
          // style: TextStyle(
          //   color: Color.fromARGB(255, 106, 120, 145),
          // ),
        ),
        textTheme: themeData.primaryTextTheme,
        actions: <Widget>[
          //导航栏右侧菜单
          IconButton(
              icon: Icon(Icons.menu),
              // color: Color.fromARGB(255, 106, 120, 145),
              onPressed: () {}),
          SizedBox(
            width: 80,
          ),
        ],
        // color: Color.fromARGB(255, 106, 120, 145),
        centerTitle: false,
      ),
      body: Container(
        color: themeData.accentColor,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints.expand(),
            child: Scrollbar(
              child: ListView(
                reverse: false,
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: ListTile.divideTiles(
                        context: context,
                        tiles: _items.map<Widget>(buildListTile).toList())
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
