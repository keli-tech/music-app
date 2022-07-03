import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Tile “瓦片”
class Tile extends StatelessWidget {
  const Tile({
    required this.child,
    required this.selected,
    required this.radiusnum,
    this.blur,
  });

  final Widget child;
  final bool selected;
  final double radiusnum;
  final double? blur;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: themeData.backgroundColor,
              // 向上阴影
              offset: Offset(0.0, 0.0),
              blurRadius: this.blur ?? 10.0,
              spreadRadius: this.blur ?? 10.0,
            ),
            BoxShadow(
              color: Color(0x6aFFFFFF),
              // 向上阴影
              offset: Offset(0.0, 0.0),
              blurRadius: 0.450,
              spreadRadius: 0.060,
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(this.radiusnum)),
          // 选中的颜色
          color: this.selected
              ? themeData.selectedRowColor
              : themeData.unselectedWidgetColor,
        ),
        child: this.child,
      ),
    );
  }
}
