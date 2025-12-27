// Not required for test files
// ignore_for_file: leading_newlines_in_multiline_strings

import 'package:berry_lang/berry_lang.dart';
import 'package:test/test.dart';

void main() {
  group('BerryLang', () {
    test('can be instantiated', () {
      expect(BerryLangRuntime(), isNotNull);
    });

    group('statements', () {
      group('let statements', () {
        test('is correctly parsed', () {
          final berryRuntime = BerryLangRuntime()
            ..loadProgram('''10 LET A = 10''');

          final line = berryRuntime.getLine(10);
          expect(line, isNotNull);
          expect(line!.number, equals(10));

          final statement = line.statement;
          expect(
            statement,
            isA<LetStatement>().having(
              (s) => s.variable,
              'variable',
              equals('A'),
            ),
          );
        });
        test('sets a value in a variable', () {
          final berryRuntime = BerryLangRuntime()
            ..loadProgram('''10 LET A = 10''')
            ..runProgram();

          expect(berryRuntime.getVariable('A'), equals(10));
        });

        test('sets a value from a variable', () {
          final berryRuntime = BerryLangRuntime()
            ..loadProgram('''10 LET A = 10
20 LET B = A''')
            ..runProgram();

          expect(berryRuntime.getVariable('A'), equals(10));
          expect(berryRuntime.getVariable('B'), equals(10));
        });

        test('sets a value from an add operation', () {
          final berryRuntime = BerryLangRuntime()
            ..loadProgram('''10 LET A = 10 + 12''')
            ..runProgram();

          expect(berryRuntime.getVariable('A'), equals(22));
        });

        test('sets a value from a complex expression', () {
          final berryRuntime = BerryLangRuntime()
            ..loadProgram('''10 LET A = 10 + 2 + 3 + 5 + 1''')
            ..runProgram();

          expect(berryRuntime.getVariable('A'), equals(21));
        });

        test('sets a value from a subtract operation', () {
          final berryRuntime = BerryLangRuntime()
            ..loadProgram('''10 LET A = 20 - 5''')
            ..runProgram();

          expect(berryRuntime.getVariable('A'), equals(15));
        });

        test('sets a value from mixed operations', () {
          final berryRuntime = BerryLangRuntime()
            ..loadProgram('''10 LET A = 50 - 20 + 5 + 10 - 2''')
            ..runProgram();

          expect(berryRuntime.getVariable('A'), equals(43));
        });

        test('sets a value from an operation between variables', () {
          final berryRuntime = BerryLangRuntime()
            ..loadProgram('''10 LET A = 30
20 LET B = 10
30 LET C = A - B + 5''')
            ..runProgram();

          expect(berryRuntime.getVariable('A'), equals(30));
          expect(berryRuntime.getVariable('B'), equals(10));
          expect(berryRuntime.getVariable('C'), equals(25));
        });

        test('variables are 0 bt default', () {
          final berryRuntime = BerryLangRuntime()
            ..loadProgram('''10 LET A = B + 1''')
            ..runProgram();

          expect(berryRuntime.getVariable('A'), equals(1));
        });
      });

      group('GOTO statements', () {
        test('is correctly parsed', () {
          final berryRuntime = BerryLangRuntime()
            ..loadProgram('''10 GOTO 20''');
          final line = berryRuntime.getLine(10);
          expect(line, isNotNull);
          expect(line!.number, equals(10));
          final statement = line.statement;
          expect(
            statement,
            isA<GotoStatement>().having(
              (s) => s.targetLine,
              'targetLine',
              equals(20),
            ),
          );
        });

        test('jumpts to the target line', () {
          final berryRuntime = BerryLangRuntime()
            ..loadProgram('''10 LET A = 30
20 GOTO 40
30 LET A = 10
40 LET A = A + 20''')
            ..runProgram();

          // If goto worked, A should be 50 (30 + 20) instead of 30
          expect(berryRuntime.getVariable('A'), equals(50));
        });
      });

      group('IF statements', () {
        test('is correctly parsed', () {
          final berryRuntime = BerryLangRuntime()
            ..loadProgram('''10 IF A > B GOTO 20''');
          final line = berryRuntime.getLine(10);
          expect(line, isNotNull);
          expect(line!.number, equals(10));
          final statement = line.statement;
          expect(
            statement,
            isA<IfStatement>().having(
              (s) => s.targetLine,
              'targetLine',
              equals(20),
            ),
          );
        });

        test('jumpts to the target line if the expression is true', () async {
          final berryRuntime = BerryLangRuntime()
            ..loadProgram('''10 LET A = A + 1
20 IF A < 5 GOTO 10''')
            ..runProgram();

          // If goto worked, A should be 5 due to the recursion
          expect(berryRuntime.getVariable('A'), equals(5));
        });

        group('when using a >= operator', () {
          test('jumpts to the target line if the expression is true', () {
            final berryRuntime = BerryLangRuntime()
              ..loadProgram('''10 LET A = 5
20 IF A >= 5 GOTO 40
30 LET A = 10
40 LET A = A + 1''')
              ..runProgram();
            // If goto worked, A should be 6 (5 + 1) instead of 10
            expect(berryRuntime.getVariable('A'), equals(6));
          });
        });
        group('when using a < operator', () {
          test('jumps to the target line if the expression is true', () {
            final berryRuntime = BerryLangRuntime()
              ..loadProgram('''10 LET A = 3
20 IF A < 5 GOTO 40
30 LET A = 10
40 LET A = A + 2''')
              ..runProgram();
            // If goto worked, A should be 5 (3 + 2) instead of 10
            expect(berryRuntime.getVariable('A'), equals(5));
          });
        });

        group('when using a <= operator', () {
          test('jumps to the target line if the expression is true', () {
            final berryRuntime = BerryLangRuntime()
              ..loadProgram('''10 LET A = 5
20 IF A <= 5 GOTO 40
30 LET A = 10
40 LET A = A + 3''')
              ..runProgram();
            // If goto worked, A should be 8 (5 + 3) instead of 10
            expect(berryRuntime.getVariable('A'), equals(8));
          });
        });

        group('when using a = operator', () {
          test('jumps to the target line if the expression is true', () {
            final berryRuntime = BerryLangRuntime()
              ..loadProgram('''10 LET A = 7
20 IF A = 7 GOTO 40
30 LET A = 10
40 LET A = A + 4''')
              ..runProgram();
            // If goto worked, A should be 11 (7 + 4) instead of 10
            expect(berryRuntime.getVariable('A'), equals(11));
          });
        });

        group('when using a <> operator', () {
          test('jumps to the target line if the expression is true', () {
            final berryRuntime = BerryLangRuntime()
              ..loadProgram('''10 LET A = 2
20 IF A <> 5 GOTO 40
30 LET A = 10
40 LET A = A + 6''')
              ..runProgram();
            // If goto worked, A should be 8 (2 + 6) instead of 10
            expect(berryRuntime.getVariable('A'), equals(8));
          });
        });
      });
    });

    group('custom statements', () {
      test('can register a custom statement parser', () async {
        final berryRuntime = BerryLangRuntime()
          ..registerStatementParser('SUPER', _SuperValueStatement.fromTokens)
          ..loadProgram('''10 SUPER A''')
          ..runProgram();
        expect(berryRuntime.getVariable('A'), equals(42));
      });
    });

    group('custom start line', () {
      test('can start execution from a specific line', () {
        final berryRuntime = BerryLangRuntime()
          ..loadProgram('''10 LET A = 2
20 LET A = A + 1''')
          ..runProgram();

        expect(berryRuntime.getVariable('A'), equals(3));

        berryRuntime.runProgram(startLine: 20);
        expect(berryRuntime.getVariable('A'), equals(4));
      });
    });
  });
}

class _SuperValueStatement extends ProgramStatement {
  _SuperValueStatement({
    required this.targetVariable,
  });

  factory _SuperValueStatement.fromTokens(List<String> tokens) {
    // Expected format: PI <variable>
    if (tokens.length != 1) {
      throw const UnexpectedTokenException('Invalid PI statement format');
    }
    final targetVariable = tokens[0];
    return _SuperValueStatement(targetVariable: targetVariable);
  }

  final String targetVariable;

  @override
  int? execute(BerryLangRuntime runtime) {
    runtime.setVariable(targetVariable, 42);
    return null;
  }
}
