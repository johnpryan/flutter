import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

import 'dart:ui' show lerpDouble;

import '../../scheduler.dart';

/// A widget that applies animated effects to its child.
class Animated extends StatefulWidget {
  /// Creates a widget that applies animated effects to its child.
  const Animated({
    super.key,
    this.curve = Curves.linear,
    required this.child,
    required this.value,
  });

  /// The widget to apply animated effects to.
  final Widget child;

  /// The curve to apply when animating the parameters of this container.
  final Curve curve;

  final Object? value;

  @override
  State<Animated> createState() => AnimatedState();
}

/// The state for the [Animated] widget.
class AnimatedState extends State<Animated> with SingleTickerProviderStateMixin {
  late AnimationController controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  @override
  void initState() {
    super.initState();
  }

  CurvedAnimation _createCurve() {
    return CurvedAnimation(parent: controller, curve: widget.curve);
  }

  Animation<double> get animation => _animation;
  late CurvedAnimation _animation = _createCurve();

  @override
  void didUpdateWidget(Animated oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.curve != oldWidget.curve) {
      _animation.dispose();
      _animation = _createCurve();
    }

    if (widget.value != oldWidget.value) {
      // print('forward() called in AnimatedState.didUpdateWidget');
      // SchedulerBinding.instance.addPostFrameCallback((_) {
      //   print('in postFrameCallback');
      // forward();
      // });
    }
  }

  void forward() {
    if (controller.status == AnimationStatus.dismissed) {
      controller.forward();
    } else if (controller.status == AnimationStatus.completed) {
      controller
        ..value = 0.0
        ..forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedNotifier(
      notifier: animation,
      child: widget.child,
    );
  }
}

class AnimatedNotifier extends InheritedNotifier<Animation<double>> {
  const AnimatedNotifier({
    super.key,
    super.notifier,
    required super.child,
  });


  static AnimatedNotifier of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AnimatedNotifier>()!;
  }
}

mixin AnimatableWidgetMixin {
  void forEachTween(TweenVisitor<dynamic> visitor);

  bool _shouldAnimateTween(Tween<dynamic> tween, dynamic targetValue) {
    return targetValue != (tween.end ?? tween.begin);
  }

  void _updateTween(Tween<dynamic>? tween, dynamic targetValue, Animation<double> animation) {
    if (tween == null) {
      return;
    }
    tween
      ..begin = tween.evaluate(animation)
      ..end = targetValue;
  }

  bool constructTweens() {
    bool shouldStartAnimation = false;
    forEachTween((Tween<dynamic>? tween, dynamic targetValue,
        TweenConstructor<dynamic> constructor) {
      if (targetValue != null) {
        tween ??= constructor(targetValue);
        if (_shouldAnimateTween(tween, targetValue)) {
          shouldStartAnimation = true;
        } else {
          tween.end ??= tween.begin;
        }
      } else {
        tween = null;
      }
      return tween;
    });
    return shouldStartAnimation;
  }

  void updateTweens(AnimatedState? animatedState) {
    // TODO: is it always OK to skip updating tweens when state is null?
    if (animatedState == null) {
      return;
    }

    if (constructTweens()) {
      forEachTween((Tween<dynamic>? tween, dynamic targetValue,
          TweenConstructor<dynamic> constructor) {
        _updateTween(tween, targetValue, animatedState.animation);
        return tween;
      });
      // print('animatedState.forward() called in constructTweens()');
      animatedState.forward();
    }
  }
}

/// Adds [animated] extension to [Widget].
///
extension AnimateWidgetExtensions on Widget {
  /// Wraps the target [Widget] in an [Animate] instance, and returns
  /// the instance for chaining calls.
  /// Ex. `myWidget.animate()` is equivalent to `Animate(child: myWidget)`.
  Animated animated({
    Key? key,
    bool? autoPlay,
    Duration? delay,
    AnimationController? controller,
    double? target,
    required Object? value,
  }) =>
      Animated(
        key: key,
        value: value,
        child: this,
      );
}
