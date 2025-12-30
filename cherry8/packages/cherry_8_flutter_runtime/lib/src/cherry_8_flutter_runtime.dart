import 'dart:async';

import 'package:cherry_8_runtime/cherry_8_runtime.dart';
import 'package:flutter/material.dart';

/// {@template cherry_8_game_view}
/// A Cherry8 runtime for flutter
/// {@endtemplate}
class Cherry8GameView extends StatefulWidget {
  /// {@macro cherry_8_game_view}
  const Cherry8GameView({
    required this.cartridgeCode,
    super.key,
  });

  /// The cartridge code to run
  final String cartridgeCode;

  @override
  State<Cherry8GameView> createState() => _Cherry8GameViewState();
}

class _Cherry8GameViewState extends State<Cherry8GameView> {
  late final _runtime = Cherry8Runtime();

  late final Future<void> _initializeFuture = _runtime.loadCartridge(
    widget.cartridgeCode,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return _Cherry8RuntimeView(runtime: _runtime);
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class _Cherry8RuntimeView extends StatefulWidget {
  const _Cherry8RuntimeView({
    required this.runtime,
  });

  final Cherry8Runtime runtime;

  @override
  State<_Cherry8RuntimeView> createState() => _Cherry8RuntimeViewState();
}

class _Cherry8RuntimeViewState extends State<_Cherry8RuntimeView> {
  @override
  void initState() {
    super.initState();

    widget.runtime.addTickListener(_onTick);
    unawaited(widget.runtime.startLoop());
  }

  @override
  void dispose() {
    widget.runtime.removeTickListener(_onTick);
    widget.runtime.stopLoop();
    super.dispose();
  }

  void _onTick() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color.fromARGB(255, 151, 147, 142),
      child: AspectRatio(
        aspectRatio:
            Cherry8Runtime.resolution.$1 / Cherry8Runtime.resolution.$2,
        child: CustomPaint(
          painter: _Cherry8Painter(runtime: widget.runtime),
        ),
      ),
    );
  }
}

class _Cherry8Painter extends CustomPainter {
  _Cherry8Painter({
    required this.runtime,
  });

  final Cherry8Runtime runtime;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final pixelWidth = size.width / Cherry8Runtime.resolution.$1;
    final pixelHeight = size.height / Cherry8Runtime.resolution.$2;

    for (var y = 0; y < Cherry8Runtime.resolution.$2; y++) {
      for (var x = 0; x < Cherry8Runtime.resolution.$1; x++) {
        if (runtime.pixelState(x, y) == 1) {
          final rect = Rect.fromLTWH(
            x * pixelWidth,
            y * pixelHeight,
            pixelWidth,
            pixelHeight,
          );
          canvas.drawRect(rect, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
