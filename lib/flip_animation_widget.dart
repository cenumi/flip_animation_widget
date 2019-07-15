library flip_animation_widget;

import 'package:flutter/material.dart';
import 'dart:math';

class RotateAnimatedBuilder extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final AxisDirection direction;

  RotateAnimatedBuilder({this.child, this.animation, this.direction});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: _getTransform(direction),
            child: child,
            );
        },
        child: child);
  }

  _getTransform(AxisDirection direction) {
    final m = Matrix4.identity()..setEntry(3, 2, 0.001);
    switch (direction) {
      case AxisDirection.left:
        m.rotateY(animation.value);
        break;
      case AxisDirection.right:
        m.rotateY(-animation.value);
        break;
      case AxisDirection.up:
        m.rotateX(animation.value);
        break;
      case AxisDirection.down:
        m.rotateX(-animation.value);
        break;
    }
    return m;
  }
}

class Flipper extends StatefulWidget {
  final Widget front;
  final Widget back;
  final bool value;
  final Function(bool value) onFlip;
  final GestureLongPressCallback onLongPress;
  final int duration;
  final AxisDirection direction;

  Flipper({@required this.front, @required this.back, @required this.onFlip, this.direction = AxisDirection.left, this.duration = 500, this.value = false, this.onLongPress});

  @override
  _FlipperState createState() => _FlipperState();
}

class _FlipperState extends State<Flipper> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animationFront;
  Animation<double> _animationBack;


  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: widget.duration));
    _animationFront = TweenSequence([TweenSequenceItem(tween: Tween(begin: 0.0, end: pi / 2), weight: 1), TweenSequenceItem(tween: ConstantTween(pi / 2), weight: 1)]).animate(_animationController);
    _animationBack = TweenSequence([TweenSequenceItem(tween: ConstantTween(pi / 2), weight: 1), TweenSequenceItem(tween: Tween(begin: -pi / 2, end: 0.0), weight: 1)]).animate(_animationController);

    if(widget.value){
      _animationController.reverse();
    }else{
      _animationController.forward();
    }
    super.initState();
  }


  @override
  void didUpdateWidget(Flipper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.value != widget.value){
      if(widget.value){
        _animationController.reverse();
      }else{
        _animationController.forward();
      }
    }
  }

  toggleCard() {
    widget.onFlip(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        onTap: toggleCard,
        onLongPress: widget.onLongPress,
        behavior: HitTestBehavior.translucent,
        child: Stack(children: [_buildContent(widget.value),_buildContent(!widget.value)]),
        ),
      );
  }


  _buildContent(bool front) =>IgnorePointer(
    ignoring: !front,
    child: RotateAnimatedBuilder(
      child: front?widget.front:widget.back,
      animation: front?_animationFront:_animationBack,
      direction: widget.direction,
      ),
    );

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}