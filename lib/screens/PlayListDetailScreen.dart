import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math' as math;
import '../services/EventBus.dart';

class PlayListDetailScreen extends StatefulWidget {
  const PlayListDetailScreen({this.color, this.colorName, this.index});

  final Color color;
  final String colorName;
  final int index;

  @override
  State<StatefulWidget> createState() => PlayListDetailScreenState();
}

class PlayListDetailScreenState extends State<PlayListDetailScreen> {
  @override
  void initState() {
    super.initState();
    relatedColors = List<Color>.generate(10, (int index) {
      final math.Random random = math.Random();
      return Color.fromARGB(
        255,
        (widget.color.red + random.nextInt(100) - 50).clamp(0, 255),
        (widget.color.green + random.nextInt(100) - 50).clamp(0, 255),
        (widget.color.blue + random.nextInt(100) - 50).clamp(0, 255),
      );
    });
  }

  List<Color> relatedColors;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        trailing: ExitButton(),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: ListView(
          children: <Widget>[
            const Padding(padding: EdgeInsets.only(top: 16.0)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    height: 128.0,
                    width: 128.0,
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(left: 18.0)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          widget.colorName,
                          style: const TextStyle(
                              fontSize: 24.0, fontWeight: FontWeight.bold),
                        ),
                        const Padding(padding: EdgeInsets.only(top: 6.0)),
                        Text(
                          'Item number ${widget.index}',
                          style: TextStyle(
                            color: CupertinoDynamicColor.resolve(
                                CupertinoColors.secondaryLabel, context),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(top: 20.0)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            CupertinoButton.filled(
                              minSize: 30.0,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              borderRadius: BorderRadius.circular(32.0),
                              child: const Text(
                                'Play',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.28,
                                ),
                              ),
                              onPressed: () {
                                eventBus
                                    .fire(MusicPlayEvent(MusicPlayAction.play));
                              },
                            ),
                            CupertinoButton.filled(
                              minSize: 30.0,
                              padding: EdgeInsets.zero,
                              borderRadius: BorderRadius.circular(32.0),
                              child: const Icon(CupertinoIcons.ellipsis),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 28.0, bottom: 8.0),
              child: Text(
                'USERS ALSO LIKED',
                style: TextStyle(
                  color: Color(0xFF646464),
                  letterSpacing: -0.60,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              height: 200.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemExtent: 160.0,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: relatedColors[index],
                      ),
                      child: Center(
                        child: CupertinoButton(
                          child: const Icon(
                            CupertinoIcons.plus_circled,
                            color: CupertinoColors.white,
                            size: 36.0,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExitButton extends StatelessWidget {
  const ExitButton();

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: const Tooltip(
        message: 'Back',
        child: Text('Exit'),
        excludeFromSemantics: true,
      ),
      onPressed: () {
        // The demo is on the root navigator.
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
  }
}
