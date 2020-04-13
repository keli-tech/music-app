import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/EventBus.dart';

/**
 * 
 * 列表页
 */

class MusicListScreen extends StatefulWidget {
  MusicListScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MusicListScreenState createState() => _MusicListScreenState();
}

class _ListItem {
  _ListItem(this.value, this.checkState);

  final String value;

  bool checkState;
}

class _MusicListScreenState extends State<MusicListScreen> {
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
        title: Text('The Phoenix'),
        subtitle: Text('Fall Out Boy - Save Rock And Roll'),
        isThreeLine: false,

        // CircleAvatar(child: Text('asdf'))
        // title: new Text('sadf'),
        trailing: new Icon(Icons.keyboard_arrow_right),
        onTap: () {
          eventBus.fire(MusicPlayEvent(MusicPlayAction.play));
        },
        enabled: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Scaffold(
      // backgroundColor: Color.fromARGB(255, 231, 240, 253),
      appBar: AppBar(
        // backgroundColor: Color.fromARGB(255, 225, 235, 250),
        title: Text(
          widget.title,
          // style: TextStyle(
          //   color: Color.fromARGB(255, 106, 120, 145),
          // ),
        ),
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
                      .toList()),
            ),
          ),
        ),
      ),
    );
  }
}
