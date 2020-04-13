import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RotateTransform extends StatelessWidget {
  RotateTransform({this.child, this.animation});

  final Widget child;
  final Animation<double> animation;

  Widget build(BuildContext context) {
    return new Center(
      child: new AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget child) {
            return Transform.rotate(
                angle: math.pi / 360 * animation.value, child: child);
          },
          child: child),
    );
  }
}
