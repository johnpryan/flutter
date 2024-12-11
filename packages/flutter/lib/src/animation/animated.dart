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
