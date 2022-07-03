import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/models/MusicInfoModel.dart';
import 'package:hello_world/services/FileManager.dart';

class AlbumImageAnimation extends StatelessWidget {
  final Animation<double> controller;
  final MusicInfoModel musicInfoModel;
  final double windowWidth;
  final double windowHeight;
  final double bottomBarHeight;

  Animation<EdgeInsets> padding1 = 0 as Animation<EdgeInsets>;
  Animation<EdgeInsets> padding2 = 0 as Animation<EdgeInsets>;
  Animation<EdgeInsets> padding3 = 0 as Animation<EdgeInsets>;

  Animation<double> scala1 = 0 as Animation<double>;
  Animation<double> scala2 = 0 as Animation<double>;
  Animation<double> scala3 = 0 as Animation<double>;

  Animation<double> angle1 = 0 as Animation<double>;
  Animation<double> angle2 = 0 as Animation<double>;
  Animation<double> angle3 = 0 as Animation<double>;

  AlbumImageAnimation({
    Key? key,
    required this.controller,
    required this.musicInfoModel,
    required this.windowWidth,
    required this.windowHeight,
    required this.bottomBarHeight,
  }) : super(key: key) {
    angle1 = Tween<double>(
      begin: 0.0,
      end: 3.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.0, 0.1, //间隔，前60%的动画时间
          curve: Curves.ease,
        ),
      ),
    );

    angle2 = Tween<double>(
      begin: 0.0,
      end: 1.4,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.101,
          0.35,
          curve: Curves.ease,
        ),
      ),
    );

    angle3 = Tween<double>(
      begin: 0,
      end: 2.5,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.301,
          0.99,
          curve: Curves.ease,
        ),
      ),
    );

    scala1 = Tween<double>(
      begin: 8,
      end: 10,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.0, 0.17, //间隔，前60%的动画时间
          curve: Curves.ease,
        ),
      ),
    );

    scala2 = Tween<double>(
      begin: 0.0,
      end: -7.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.17,
          0.3,
          curve: Curves.ease,
        ),
      ),
    );
    scala3 = Tween<double>(
      begin: 0.0,
      end: -2.1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.4,
          0.99,
          curve: Curves.ease,
        ),
      ),
    );

    padding1 = Tween<EdgeInsets>(
      begin: EdgeInsets.only(bottom: windowHeight - 100.0),
      end: EdgeInsets.only(bottom: windowHeight - 200),
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.0, 0.10, //间隔，后40%的动画时间
          curve: Curves.ease,
        ),
      ),
    );

    padding2 = Tween<EdgeInsets>(
      begin: EdgeInsets.only(bottom: 0.0),
      end: EdgeInsets.only(bottom: 350 - windowHeight),
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.10, 0.4, //间隔，后40%的动画时间
          curve: Curves.ease,
        ),
      ),
    );

    padding3 = Tween<EdgeInsets>(
      begin: EdgeInsets.only(bottom: 0.0),
      end: EdgeInsets.only(bottom: -100 + bottomBarHeight),
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.4, 1.0, //间隔，后40%的动画时间
          curve: Curves.linear,
        ),
      ),
    );
  }

  Widget _buildAnimation(BuildContext context, Widget? child) {
    return Container(
      width: 1000,
      alignment: Alignment.bottomCenter,
      padding: padding1.value + padding2.value + padding3.value,
      child: Container(
        child: Transform.scale(
          scale: scala1.value + scala2.value + scala3.value,
          child: Transform.rotate(
            angle: angle1.value + angle2.value + angle3.value,
            child: CircleAvatar(
              backgroundImage: AssetImage("assets/images/heijiao-record.png"),
              radius: 32, // --> 半径越大，图片越大
              child: Center(
                child: Container(
                  key: Key("start"),
                  height: 40.0,
                  width: 40.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    image: DecorationImage(
                        fit: BoxFit.fill, //这个地方很重要，需要设置才能充满
                        image: FileManager.musicAlbumPictureImage(
                            musicInfoModel.artist,
                            musicInfoModel.album)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: _buildAnimation,
      animation: controller,
    );
  }
}
