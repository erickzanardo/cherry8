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
        test('sets a value in a variable', () async {
          final berryRuntime = BerryLangRuntime()
            ..loadProgram('''10 LET A = 10''');

          await berryRuntime.runProgram();

          expect(berryRuntime.getVariable('A'), equals(10));
        });

        test('sets a value from a variable', () async {
          final berryRuntime = BerryLangRuntime()
            ..loadProgram('''10 LET A = 10
20 LET B = A''');

          await berryRuntime.runProgram();

          expect(berryRuntime.getVariable('A'), equals(10));
          expect(berryRuntime.getVariable('B'), equals(10));
        });

        test('sets a value from an add operation', () async {
          final berryRuntime = BerryLangRuntime()
            ..loadProgram('''10 LET A = 10 + 12''');

          await berryRuntime.runProgram();

          expect(berryRuntime.getVariable('A'), equals(22));
        });

        test('sets a value from a complex expression', () async {
          final berryRuntime = BerryLangRuntime()
            ..loadProgram('''10 LET A = 10 + 2 + 3 + 5 + 1''');

          await berryRuntime.runProgram();

          expect(berryRuntime.getVariable('A'), equals(21));
        });

        test('sets a value from a subtract operation', () async {
          final berryRuntime = BerryLangRuntime()
            ..loadProgram('''10 LET A = 20 - 5''');

          await berryRuntime.runProgram();

          expect(berryRuntime.getVariable('A'), equals(15));
        });

        test('sets a value from mixed operations', () async {
          final berryRuntime = BerryLangRuntime()
            ..loadProgram('''10 LET A = 50 - 20 + 5 + 10 - 2''');

          await berryRuntime.runProgram();

          expect(berryRuntime.getVariable('A'), equals(43));
        });

        test('sets a value from an operation between variables', () async {
          final berryRuntime = BerryLangRuntime()
            ..loadProgram('''10 LET A = 30
20 LET B = 10
30 LET C = A - B + 5''');

          await berryRuntime.runProgram();

          expect(berryRuntime.getVariable('A'), equals(30));
          expect(berryRuntime.getVariable('B'), equals(10));
          expect(berryRuntime.getVariable('C'), equals(25));
        });

        test('variables are 0 bt default', () async {
          final berryRuntime = BerryLangRuntime()
            ..loadProgram('''10 LET A = B + 1''');

          await berryRuntime.runProgram();

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

        test('jumpts to the target line', () async {
          final berryRuntime = BerryLangRuntime()
            ..loadProgram('''10 LET A = 30
20 GOTO 40
30 LET A = 10
40 LET A = A + 20''');

          await berryRuntime.runProgram();

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
20 IF A < 5 GOTO 10''');

          await berryRuntime.runProgram();

          // If goto worked, A should be 5 due to the recursion
          expect(berryRuntime.getVariable('A'), equals(5));
        });

        group('when using a >= operator', () {
          test('jumpts to the target line if the expression is true', () async {
            final berryRuntime = BerryLangRuntime()
              ..loadProgram('''10 LET A = 5
20 IF A >= 5 GOTO 40
30 LET A = 10
40 LET A = A + 1''');
            await berryRuntime.runProgram();
            // If goto worked, A should be 6 (5 + 1) instead of 10
            expect(berryRuntime.getVariable('A'), equals(6));
          });
        });
        group('when using a < operator', () {
          test('jumps to the target line if the expression is true', () async {
            final berryRuntime = BerryLangRuntime()
              ..loadProgram('''10 LET A = 3
20 IF A < 5 GOTO 40
30 LET A = 10
40 LET A = A + 2''');
            await berryRuntime.runProgram();
            // If goto worked, A should be 5 (3 + 2) instead of 10
            expect(berryRuntime.getVariable('A'), equals(5));
          });
        });

        group('when using a <= operator', () {
          test('jumps to the target line if the expression is true', () async {
            final berryRuntime = BerryLangRuntime()
              ..loadProgram('''10 LET A = 5
20 IF A <= 5 GOTO 40
30 LET A = 10
40 LET A = A + 3''');
            await berryRuntime.runProgram();
            // If goto worked, A should be 8 (5 + 3) instead of 10
            expect(berryRuntime.getVariable('A'), equals(8));
          });
        });

        group('when using a = operator', () {
          test('jumps to the target line if the expression is true', () async {
            final berryRuntime = BerryLangRuntime()
              ..loadProgram('''10 LET A = 7
20 IF A = 7 GOTO 40
30 LET A = 10
40 LET A = A + 4''');
            await berryRuntime.runProgram();
            // If goto worked, A should be 11 (7 + 4) instead of 10
            expect(berryRuntime.getVariable('A'), equals(11));
          });
        });

        group('when using a <> operator', () {
          test('jumps to the target line if the expression is true', () async {
            final berryRuntime = BerryLangRuntime()
              ..loadProgram('''10 LET A = 2
20 IF A <> 5 GOTO 40
30 LET A = 10
40 LET A = A + 6''');
            await berryRuntime.runProgram();
            // If goto worked, A should be 8 (2 + 6) instead of 10
            expect(berryRuntime.getVariable('A'), equals(8));
          });
        });
      });
    });
  });
}
