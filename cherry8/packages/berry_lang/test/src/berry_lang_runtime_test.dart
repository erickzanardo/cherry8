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
      });
    });
  });
}
