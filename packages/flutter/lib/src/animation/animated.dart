import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

import 'dart:ui' show lerpDouble;

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
  }

  void forward() {
    print(' forward:  ${controller.status}');
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
    print('Animated Widget build()');
    return AnimatedNotifier(
      notifier: animation,
      child: widget.child,
    );
  }
}

class AnimatableValue<T> {
  AnimatableValue({double value = 0.0}) : _value = value;

  double _value = 0.0;
  double _oldValue = 0.0;
  Animation<double>? animation;
  AnimationController? controller;
  bool shouldAnimate = false;

  set value(double v) {
    print('set value: $v');
    if (_value == v) return;
    _oldValue = _value;
    _value = v;
    // shouldAnimate = true;
    print('oldValue: $_oldValue , value: $_value');
  }

  double get value {
    print('get value: $_value');
    if (animation == null) {
      print(' animation is null, return value: $_value');
      return _value;
    }
    return lerpDouble(_oldValue, _value, animation!.value)!;
  }

  // Override * operator
  AnimatableValue<T> operator *(double scalar) {
    return ReadonlyAnimatableValue(parent: this, scalar: scalar);
  }
}

class ReadonlyAnimatableValue<T> extends AnimatableValue<T> {
  ReadonlyAnimatableValue({
    required this.parent,
    this.scalar = 1.0,
  });

  AnimatableValue<T>? parent;
  double scalar = 1.0;
  double get value {
    return parent!.value * scalar!;
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

  @override
  bool updateShouldNotify(AnimatedNotifier oldWidget) =>
      notifier?.value != oldWidget.notifier?.value;
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
