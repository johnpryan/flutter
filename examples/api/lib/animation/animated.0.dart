import 'package:flutter/material.dart';

import 'package:flutter/animation.dart';

void main() {
  runApp(ScaleEffectApp());
}

class ScaleEffectApp extends StatelessWidget {
  ScaleEffectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ScaleEffectScreen(),
    );
  }
}

class ScaleEffectScreen extends StatelessWidget {
  const ScaleEffectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: MyAnimatedButton(),
      ),
    );
  }
}

class MyAnimatedButton extends StatefulWidget {
  const MyAnimatedButton({super.key});

  @override
  State<MyAnimatedButton> createState() => _MyAnimatedButtonState();
}

class _MyAnimatedButtonState extends State<MyAnimatedButton> {
  final AnimatableValue<double> scale = AnimatableValue<double>(value: 1.0);
  final startScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < 2; i++)
              Container(
                height: scale * 50,
                width: scale * 100,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      scale.value += 1;
                    });
                  },
                  child: const Text("Press here"),
                ),
              ),
          ],
        ).animated(value: scale),

      ],
    );
  }

  void withAnimation(AnimatableValue<double> value, void Function() callback) {
    callback();
  }
}
