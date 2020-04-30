// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

const Duration _bottomSheetDuration = Duration(milliseconds: 350);
const double _minFlingVelocity = 500.0;
const double _closeProgressThreshold = 0.5;
const double _willPopThreshold = 0.8;

typedef ScrollWidgetBuilder = Widget Function(
    BuildContext context, ScrollController controller);

typedef WidgetWithChildBuilder = Widget Function(
    BuildContext context, Animation<double> animation, Widget child);

/// A custom bottom sheet.
///
/// The [ModalBottomSheet] widget itself is rarely used directly. Instead, prefer to
/// create a modal bottom sheet with [showMaterialModalBottomSheet].
///
/// See also:
///
///  * [showMaterialModalBottomSheet] which can be used to display a modal bottom
///    sheet with Material appareance.
///  * [showCupertinoModalBottomSheet] which can be used to display a modal bottom
///    sheet with Cupertino appareance.
class ModalBottomSheet extends StatefulWidget {
  /// Creates a bottom sheet.
  const ModalBottomSheet({
    Key key,
    this.animationController,
    this.enableDrag = true,
    this.containerBuilder,
    this.bounce = true,
    this.shouldClose,
    this.scrollController,
    this.expanded,
    @required this.onClosing,
    @required this.builder,
  })  : assert(enableDrag != null),
        assert(onClosing != null),
        assert(builder != null),
        super(key: key);

  /// The animation controller that controls the bottom sheet's entrance and
  /// exit animations.
  ///
  /// The BottomSheet widget will manipulate the position of this animation, it
  /// is not just a passive observer.
  final AnimationController animationController;

  /// Allows the bottom sheet to  go beyond the top bound of the content,
  /// but then bounce the content back to the edge of
  /// the top bound.
  final bool bounce;

  final bool expanded;

  final WidgetWithChildBuilder containerBuilder;

  /// Called when the bottom sheet begins to close.
  ///
  /// A bottom sheet might be prevented from closing (e.g., by user
  /// interaction) even after this callback is called. For this reason, this
  /// callback might be call multiple times for a given bottom sheet.
  final Function() onClosing;

  // If shouldClose is null is ignored.
  // If returns true => The dialog closes
  // If returns false => The dialog cancels close
  // Notice that if shouldClose is not null, the dialog will go back to the
  // previous position until the function is solved
  final Future<bool> Function() shouldClose;

  /// A builder for the contents of the sheet.
  ///
  final ScrollWidgetBuilder builder;

  /// If true, the bottom sheet can be dragged up and down and dismissed by
  /// swiping downwards.
  ///
  /// Default is true.
  final bool enableDrag;

  final ScrollController scrollController;

  @override
  _ModalBottomSheetState createState() => _ModalBottomSheetState();

  /// Creates an [AnimationController] suitable for a
  /// [ModalBottomSheet.animationController].
  ///
  /// This API available as a convenience for a Material compliant bottom sheet
  /// animation. If alternative animation durations are required, a different
  /// animation controller could be provided.
  static AnimationController createAnimationController(TickerProvider vsync) {
    return AnimationController(
      duration: _bottomSheetDuration,
      debugLabel: 'BottomSheet',
      vsync: vsync,
    );
  }
}

class _ModalBottomSheetState extends State<ModalBottomSheet>
    with TickerProviderStateMixin {
  final GlobalKey _childKey = GlobalKey(debugLabel: 'BottomSheet child');

  ScrollController _scrollController;

  AnimationController _bounceDragController;

  double get _childHeight {
    final renderBox = _childKey.currentContext.findRenderObject() as RenderBox;
    return renderBox.size.height;
  }

  bool get _dismissUnderway =>
      widget.animationController.status == AnimationStatus.reverse;

  // Detect if user is dragging.
  // Used on NotificationListener to detect if ScrollNotifications are
  // before or after the user stop dragging
  bool isDragging = false;

  bool get hasReachedWillPopThreshold =>
      widget.animationController.value < _willPopThreshold;

  bool get hasReachedCloseThreshold =>
      widget.animationController.value < _closeProgressThreshold;

  void _close() {
    isDragging = false;
    widget.onClosing();
  }

  void _cancelClose() {
    widget.animationController.forward().then((value) {
      // When using WillPop, animation doesn't end at 1.
      // Check more in detail the problem
      if (!widget.animationController.isCompleted) {
        widget.animationController.value = 1;
      }
    });
    _bounceDragController.reverse();
  }

  bool _isCheckingShouldClose = false;

  FutureOr<bool> shouldClose() async {
    if (_isCheckingShouldClose) return false;
    if (widget.shouldClose == null) return null;
    _isCheckingShouldClose = true;
    final result = await widget.shouldClose();
    _isCheckingShouldClose = false;
    return result;
  }

  void _handleDragUpdate(double primaryDelta) async {
    assert(widget.enableDrag, 'Dragging is disabled');

    if (_dismissUnderway) return;
    isDragging = true;

    final progress = primaryDelta / (_childHeight ?? primaryDelta);

    if (widget.shouldClose != null && hasReachedWillPopThreshold) {
      _cancelClose();
      final canClose = await shouldClose();
      if (canClose) {
        _close();
        return;
      } else {
        _cancelClose();
      }
    }

    // Bounce top
    final bounce = widget.bounce == true;
    final shouldBounce = _bounceDragController.value > 0;
    final isBouncing = (widget.animationController.value - progress) > 1;
    if (bounce && (shouldBounce || isBouncing)) {
      _bounceDragController.value -= progress * 10;
      return;
    }

    widget.animationController.value -= progress;
  }

  void _handleDragEnd(double velocity) async {
    assert(widget.enableDrag, 'Dragging is disabled');

    if (_dismissUnderway || !isDragging) return;
    isDragging = false;
    _bounceDragController.reverse();

    var canClose = true;
    if (widget.shouldClose != null && hasReachedWillPopThreshold) {
      _cancelClose();
      canClose = await shouldClose();
    }
    if (canClose) {
      // If speed is bigger than _minFlingVelocity try to close it
      if (velocity > _minFlingVelocity) {
        _close();
      } else if (hasReachedCloseThreshold) {
        if (widget.animationController.value > 0.0) {
          widget.animationController.fling(velocity: -1.0);
        }
        _close();
      } else {
        _cancelClose();
      }
    } else {
      _cancelClose();
    }
  }

  // As we cannot access the dragGesture detector of the scroll view
  // we can not know the DragDownDetails and therefore the end velocity.
  // VelocityTracker it is used to calculate the end velocity  of the scroll
  // when user is trying to close the modal by dragging
  VelocityTracker _velocityTracker;
  DateTime _startTime;

  void _handleScrollUpdate(ScrollNotification notification) {
    if (notification.metrics.pixels <= notification.metrics.minScrollExtent) {
      //Check if listener is same from scrollController
      if (!_scrollController.hasClients) return;

      if (_scrollController.position.pixels != notification.metrics.pixels) {
        return;
      }
      DragUpdateDetails dragDetails;
      if (notification is ScrollStartNotification) {
        _velocityTracker = VelocityTracker();
        _startTime = DateTime.now();
      }
      if (notification is ScrollUpdateNotification) {
        dragDetails = notification.dragDetails;
      }
      if (notification is OverscrollNotification) {
        dragDetails = notification.dragDetails;
      }
      if (dragDetails != null) {
        final duration = _startTime.difference(DateTime.now());
        final offset = Offset(0, _scrollController.offset);
        _velocityTracker.addPosition(duration, offset);
        _handleDragUpdate(dragDetails.primaryDelta);
      } else if (isDragging) {
        final velocity = _velocityTracker.getVelocity().pixelsPerSecond.dy;
        _handleDragEnd(velocity);
      }
    }
  }

  @override
  void initState() {
    _bounceDragController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    _scrollController = widget.scrollController ?? ScrollController();
    // Todo: Check if we can remove scroll Controller
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bounceAnimation = CurvedAnimation(
      parent: _bounceDragController,
      curve: Curves.slowMiddle,
//      curve: Curves.easeInQuint,
    );

    var child = widget.builder(context, _scrollController);

    if (widget.containerBuilder != null) {
      child = widget.containerBuilder(
        context,
        widget.animationController,
        child,
      );
    }

    // Todo: Add curved Animation when push and pop without gesture
//    final Animation<double> containerAnimation = CurvedAnimation(
//      parent: widget.animationController,
//      curve: Curves.easeOut,
//    );
    final Animation<double> containerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Interval(
          0.0, 1.0, //间隔
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, _) => ClipRect(
        child: CustomSingleChildLayout(
          delegate: _ModalBottomSheetLayout(
              containerAnimation.value, widget.expanded),
          child: !widget.enableDrag
              ? child
              : KeyedSubtree(
                  key: _childKey,
                  child: AnimatedBuilder(
                    animation: bounceAnimation,
                    builder: (context, _) => CustomSingleChildLayout(
                      delegate: _CustomBottomSheetLayout(bounceAnimation.value),
                      child: GestureDetector(
                        onVerticalDragUpdate: (details) =>
                            _handleDragUpdate(details.primaryDelta),
                        onVerticalDragEnd: (details) =>
                            _handleDragEnd(details.primaryVelocity),
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification notification) {
                            _handleScrollUpdate(notification);
                            return false;
                          },
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _ModalBottomSheetLayout extends SingleChildLayoutDelegate {
  _ModalBottomSheetLayout(this.progress, this.expand);

  final double progress;
  final bool expand;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: expand ? constraints.maxHeight : 0,
      maxHeight: expand ? constraints.maxHeight : constraints.minHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height * progress);
  }

  @override
  bool shouldRelayout(_ModalBottomSheetLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class _CustomBottomSheetLayout extends SingleChildLayoutDelegate {
  _CustomBottomSheetLayout(this.progress);

  final double progress;
  double childHeight;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: constraints.minHeight,
      maxHeight: constraints.maxHeight + progress * 8,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    childHeight ??= childSize.height;
    return Offset(0.0, size.height - childSize.height);
  }

  @override
  bool shouldRelayout(_CustomBottomSheetLayout oldDelegate) {
    if (progress != oldDelegate.progress) {
      childHeight = oldDelegate.childHeight;
      return true;
    }
    return false;
  }
}
