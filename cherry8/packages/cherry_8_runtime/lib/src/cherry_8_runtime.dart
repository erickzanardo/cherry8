import 'package:berry_lang/berry_lang.dart';

class _SetPixelStatement extends ProgramStatement {
  _SetPixelStatement(this.x, this.y, this.state, this._runtime);

  factory _SetPixelStatement.fromTokens(
    List<String> tokens,
    Cherry8Runtime runtime,
  ) {
    if (tokens.length != 3) {
      throw const UnexpectedTokenException(
        'Invalid number of tokens for SetPixelStatement',
      );
    }
    final x = ProgramExpression.fromTokens(tokens.sublist(0, 1));
    final y = ProgramExpression.fromTokens(tokens.sublist(1, 2));
    final state = int.tryParse(tokens[2]);
    if (state == null) {
      throw const UnexpectedTokenException(
        'Invalid parameters for SetPixelStatement',
      );
    }
    return _SetPixelStatement(x, y, state, runtime);
  }

  final ProgramExpression x;
  final ProgramExpression y;
  final int state;

  final Cherry8Runtime _runtime;

  @override
  int? execute(BerryLangRuntime runtime) {
    _runtime._pixels[(x.evaluate(runtime), y.evaluate(runtime))] = state;
    return null;
  }
}

class _RegisterIterationRoutineStatement extends ProgramStatement {
  _RegisterIterationRoutineStatement(this.targetLine, this._runtime);

  factory _RegisterIterationRoutineStatement.fromTokens(
    List<String> tokens,
    Cherry8Runtime runtime,
  ) {
    if (tokens.length != 1) {
      throw const UnexpectedTokenException(
        'Invalid number of tokens for RegisterIterationRoutineStatement',
      );
    }
    final line = int.tryParse(tokens[0]);
    if (line == null) {
      throw FormatException('Invalid line number: ${tokens[0]}');
    }
    return _RegisterIterationRoutineStatement(line, runtime);
  }

  final int targetLine;

  final Cherry8Runtime _runtime;

  @override
  int? execute(BerryLangRuntime runtime) {
    _runtime._iterationRoutineLine = targetLine;
    return null;
  }
}

/// {@template cherry_8_runtime}
/// The runtime of the Cherry8 console
/// {@endtemplate}
class Cherry8Runtime {
  /// {@macro cherry_8_runtime}
  Cherry8Runtime();

  late final _berryRuntime = BerryLangRuntime();

  late final int _iterationRoutineLine;

  final List<void Function()> _tickListeners = [];

  /// The target frames per second for the runtime.
  static const fpsTarget = 40;

  /// The resolution of the Cherry8 console.
  static const resolution = (104, 80);

  /// The underlying BerryLang runtime.
  BerryLangRuntime get berryRuntime => _berryRuntime;

  /// Loads a cartridge into the runtime.
  Future<void> loadCartridge(String source) async {
    _berryRuntime
      ..registerStatementParser(
        'RMAIN',
        (tokens) => _RegisterIterationRoutineStatement.fromTokens(tokens, this),
      )
      ..registerStatementParser(
        'SETP',
        (tokens) => _SetPixelStatement.fromTokens(tokens, this),
      )
      ..loadProgram(source)
      ..runProgram();
  }

  /// Adds a tick listener to the runtime.
  void addTickListener(void Function() listener) {
    _tickListeners.add(listener);
  }

  /// Removes a tick listener from the runtime.
  void removeTickListener(void Function() listener) {
    _tickListeners.remove(listener);
  }

  /// Returns the state of the pixel at the given coordinates.
  int pixelState(int x, int y) => _pixels[(x, y)] ?? 0;

  final Map<(int, int), int> _pixels = {};

  bool _running = false;

  /// Stops the main loop of the runtime.
  void stopLoop() {
    _running = false;
  }

  /// Starts the main loop of the runtime.
  Future<void> startLoop() async {
    if (_running) return;
    _running = true;
    const frameDuration = Duration(milliseconds: 1000 ~/ fpsTarget);
    await Future.doWhile(() async {
      final frameStart = DateTime.now();
      runIteration();
      for (final listener in _tickListeners) {
        listener();
      }
      final frameEnd = DateTime.now();
      final elapsed = frameEnd.difference(frameStart);
      final delay = frameDuration - elapsed;
      if (delay.isNegative) {
        return _running; // Immediately start the next iteration
      } else {
        await Future<void>.delayed(delay);
        return _running; // Continue the loop
      }
    });
  }

  /// Runs a single iteration of the runtime.
  void runIteration() {
    _berryRuntime.runProgram(startLine: _iterationRoutineLine);
  }
}
