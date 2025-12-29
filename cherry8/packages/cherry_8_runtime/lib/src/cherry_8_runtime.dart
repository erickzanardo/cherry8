import 'package:berry_lang/berry_lang.dart';

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

  /// The underlying BerryLang runtime.
  BerryLangRuntime get berryRuntime => _berryRuntime;

  /// Loads a cartridge into the runtime.
  Future<void> loadCartridge(String source) async {
    _berryRuntime
      ..registerStatementParser(
        'RMAIN',
        (tokens) => _RegisterIterationRoutineStatement.fromTokens(tokens, this),
      )
      ..loadProgram(source)
      ..runProgram();
  }

  /// Returns the state of the pixel at the given coordinates.
  bool pixelState(int x, int y) => _pixels[(x, y)] ?? false;

  final Map<(int, int), bool> _pixels = {};

  /// Runs a single iteration of the runtime.
  void runIteration() {
    _berryRuntime.runProgram(startLine: _iterationRoutineLine);
  }
}
