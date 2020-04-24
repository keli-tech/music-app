import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/screens/cloudservice/NextCloudFileScreen.dart';
import 'package:hello_world/services/CloudService.dart';
import 'package:nextcloud/nextcloud.dart';

class WebDavFileRowItem extends StatefulWidget {
  @override
  _WebDavFileRowItem createState() => _WebDavFileRowItem();

  WebDavFileRowItem({Key key, this.index, this.file, this.downloadedFiles})
      : super(key: key);

  int statusBarHeight;

  final int index;
  final WebDavFile file;
  List<String> downloadedFiles;
}

class _WebDavFileRowItem extends State<WebDavFileRowItem> {
  // state 0 not download 1 downloading 2 finished
  int _status = 0;

  @override
  void initState() {
    if (widget.downloadedFiles.contains(widget.file.path)) {
      setState(() {
        _status = 2;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.file.isDirectory) {
      return builderFold(context);
    } else {
      return builder(context);
    }
  }

  Widget builderFold(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    final Widget row = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute<void>(
          title: widget.file.name,
          builder: (BuildContext context) => NextCloudFileScreen(
            title: widget.file.name.toString(),
            path: widget.file.path,
          ),
        ));
      },
      child: Container(
        color:
            CupertinoDynamicColor.resolve(themeData.backgroundColor, context),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(
                left: 16.0, top: 5.0, bottom: 5.0, right: 8.0),
            child: Row(
              children: <Widget>[
                Text(
                  (widget.index + 1).toString() + '.',
                  style: themeData.textTheme.subtitle,
                ),
                SizedBox(
                  width: 5,
                ),
                Container(
                  child: Icon(
                    Icons.folder,
                    size: 40,
                    color: themeData.primaryColor,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Padding(padding: EdgeInsets.only(right: 5.0)),
                            Expanded(
                              child: Text(
                                widget.file.name,
                                maxLines: 1,
                                style: themeData.primaryTextTheme.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.only(top: 0.0)),
                      ],
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_right,
                  color: themeData.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return row;
  }

  Widget builder(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    final Widget row = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_status > 0) {
          return;
        }

        setState(() {
          _status = 1;
        });
        CloudService.nextCloudClientc.download(widget.file).then((res) {
          setState(() {
            _status = 2;
          });
        });
      },
      child: Container(
        child: SafeArea(
          top: false,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(
                left: 16.0, top: 5.0, bottom: 5.0, right: 8.0),
            child: Row(
              children: <Widget>[
                Text(
                  (widget.index + 1).toString() + '.',
                  style: themeData.textTheme.subtitle,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                widget.file.name,
                                maxLines: 1,
                                style: themeData.primaryTextTheme.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.only(top: 0.0)),
                        Text(
                          Uri.decodeComponent((widget.file.size / 1024 / 1024)
                                  .toStringAsFixed(2)
                                  .toString() +
                              "MB"),
                          style: themeData.primaryTextTheme.subtitle,
                        ),
                      ],
                    ),
                  ),
                ),
                _status == 0
                    ? Icon(
                        Icons.cloud_download,
                        color: themeData.primaryColor,
                      )
                    : (_status == 1
                        ? CupertinoActivityIndicator(
                            animating: true,
                            radius: 12,
                          )
                        : Icon(
                            Icons.check_box,
                          )),
                SizedBox(
                  width: 8,
                )
              ],
            ),
          ),
        ),
      ),
    );

    return row;
  }

  // 底部弹出菜单actionSheet
  Widget actionSheet(BuildContext context1, BuildContext context) {
    ThemeData themeData = Theme.of(context);
    var windowHeight = MediaQuery.of(context).size.height;

    return new CupertinoActionSheet(
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text(
            '新建歌单',
            style: themeData.textTheme.display1,
          ),
          onPressed: () {
            Navigator.of(context1).pop();

            showModalBottomSheet<void>(
                context: context,
                useRootNavigator: true,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return Container(
                    height: windowHeight,
                  );
                });
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            '歌单排序',
            style: themeData.textTheme.display1,
          ),
          onPressed: () {
            Navigator.pop(context1);

            showModalBottomSheet<void>(
                context: context,
                useRootNavigator: true,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return Container(
                    height: windowHeight,
                  );
                });
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(
          '取消',
          style: themeData.textTheme.display1,
        ),
        onPressed: () {
          Navigator.of(context1).pop();
        },
      ),
    );
  }
}
