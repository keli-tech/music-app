import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'PlayListDetailScreen.dart';
import 'MyHttpServer.dart';

const int _kChildCount = 50;

class PlayListScreen extends StatelessWidget {
  const PlayListScreen({this.colorItems, this.colorNameItems});

  final List<Color> colorItems;
  final List<String> colorNameItems;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: CustomScrollView(
        semanticChildCount: _kChildCount,
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
              // trailing: trailingButtons,
              ),
          SliverPadding(
            // Top media padding consumed by CupertinoSliverNavigationBar.
            // Left/Right media padding consumed by Tab1RowItem.
            padding: MediaQuery.of(context)
                .removePadding(
                  removeTop: true,
                  removeLeft: true,
                  removeRight: true,
                )
                .padding,
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Tab1RowItem(
                    index: index,
                    lastItem: index == _kChildCount - 1,
                    color: colorItems[index],
                    colorName: colorNameItems[index],
                  );
                },
                childCount: _kChildCount,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Tab1RowItem extends StatelessWidget {
  const Tab1RowItem({this.index, this.lastItem, this.color, this.colorName});

  final int index;
  final bool lastItem;
  final Color color;
  final String colorName;

  @override
  Widget build(BuildContext context) {
    final Widget row = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute<void>(
          title: colorName,
          builder: (BuildContext context) => PlayListDetailScreen(
            color: color,
            colorName: colorName,
            index: index,
          ),
        ));
      },
      child: Container(
        color: CupertinoDynamicColor.resolve(
            CupertinoColors.systemBackground, context),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(
                left: 16.0, top: 8.0, bottom: 8.0, right: 8.0),
            child: Row(
              children: <Widget>[
                Container(
                  height: 60.0,
                  width: 60.0,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      fit: BoxFit.fill, //这个地方很重要，需要设置才能充满
                      image: NetworkImage(
                          'http://p1.music.126.net/TYwiMwjbr5dfD0K44n-xww==/109951163409466795.jpg'),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(colorName),
                        const Padding(padding: EdgeInsets.only(top: 8.0)),
                        Text(
                          'Buy this cool color',
                          style: TextStyle(
                            color: CupertinoDynamicColor.resolve(
                                CupertinoColors.secondaryLabel, context),
                            fontSize: 13.0,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(
                    CupertinoIcons.plus_circled,
                    semanticLabel: 'Add',
                  ),
                  onPressed: () {
                    Navigator.of(context).push(CupertinoPageRoute<void>(
                      title: colorName,
                      builder: (BuildContext context) => MyHttpServer(
                        // color: color,
                        // colorName: colorName,
                        // index: index,
                      ),
                    ));
                  },
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(
                    CupertinoIcons.share,
                    semanticLabel: 'Share',
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (lastItem) {
      return row;
    }

    return Column(
      children: <Widget>[
        row,
        Container(
          height: 1.0,
          color:
              CupertinoDynamicColor.resolve(CupertinoColors.separator, context),
        ),
      ],
    );
  }
}
