import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/models/CloudServiceModel.dart';
import 'package:hello_world/screens/cloudservice/NextCloudFileScreen.dart';
import 'package:hello_world/services/CloudService.dart';
import 'package:hello_world/utils/webdav/file.dart';

class WebDavFileRowItem extends StatefulWidget {
  @override
  _WebDavFileRowItem createState() => _WebDavFileRowItem();

  WebDavFileRowItem({
    Key key,
    this.lastItem,
    this.index,
    this.file,
    this.filePath,
    this.downloadedFiles,
    this.level,
    this.cloudServiceModel,
  }) : super(key: key);

  final int level;
  final String filePath;
  final bool lastItem;
  final int index;
  final WebDavFile file;
  List<String> downloadedFiles;
  CloudServiceModel cloudServiceModel;
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
    var row;
    if (widget.file.isDirectory) {
      row = builderFold(context);
    } else {
      row = builder(context);
    }

    if (widget.lastItem) {
      return row;
    }

    return Column(
      children: <Widget>[
        row,
        const Divider(
          thickness: 0.5,
          endIndent: 20,
          indent: 70,
          height: 0.40,
        ),
      ],
    );
  }

  Widget builderFold(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    final Widget row = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute<void>(
          title: widget.file.name,
          builder: (BuildContext context) => NextCloudFileScreen(
            level: widget.level + 1,
            title: widget.file.name.toString(),
            path: widget.file.path,
            filePath: widget.filePath,
            cloudServiceModel: widget.cloudServiceModel,
          ),
        ));
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
                  style: themeData.primaryTextTheme.title,
                ),
                SizedBox(
                  width: 5,
                ),
                Icon(
                  Icons.folder,
                  size: 40,
                  color: themeData.primaryColor,
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
                                style: themeData.primaryTextTheme.title,
                                maxLines: 1,
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
        CloudService.cs.download(widget.filePath, widget.file).then((res) {
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
                  style: themeData.primaryTextTheme.title,
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
                                style: themeData.primaryTextTheme.title,
                                maxLines: 1,
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
                            color: Colors.greenAccent,
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
}
