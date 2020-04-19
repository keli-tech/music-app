import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/models/MusicInfoModel.dart';

class PlayingAnimation extends StatelessWidget {
  final Animation<double> controller;
  final MusicInfoModel musicInfoModel;
  final double windowWidth;
  final double windowHeight;

  Animation<EdgeInsets> padding1;
  Animation<EdgeInsets> padding2;
  Animation<EdgeInsets> padding3;

  Animation<double> scala1;
  Animation<double> scala2;
  Animation<double> scala3;

  Animation<double> angle1;
  Animation<double> angle2;
  Animation<double> angle3;

  PlayingAnimation({
    Key key,
    this.controller,
    this.musicInfoModel,
    this.windowWidth,
    this.windowHeight,
  }) : super(key: key) {
    angle1 = Tween<double>(
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
      end: EdgeInsets.only(bottom: 320 - windowHeight),
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
      end: EdgeInsets.only(bottom: -60),
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

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Container(
        key: Key("start"),
        height: 50.0,
        width: 50.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: Colors.black45,
        ),
        child: new Image.asset(
          "assets/images/playing.gif",
          width: 90,
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
