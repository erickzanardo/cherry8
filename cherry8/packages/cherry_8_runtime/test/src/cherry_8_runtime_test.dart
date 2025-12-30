// Not required for test files
// ignore_for_file: leading_newlines_in_multiline_strings

import 'package:cherry_8_runtime/cherry_8_runtime.dart';
import 'package:test/test.dart';

void main() {
  group('Cherry8Runtime', () {
    test('can be instantiated', () {
      expect(Cherry8Runtime(), isNotNull);
    });

    test('loads a cartridge', () async {
      final runtime = Cherry8Runtime();
      const cartridgeSource = '''10 RMAIN 20
20 LET A = A + 1''';
      await runtime.loadCartridge(cartridgeSource);

      runtime.runIteration();

      expect(runtime.berryRuntime.getVariable('A'), 2);
    });

    group('SETP', () {
      test('sets pixel correctly', () async {
        final runtime = Cherry8Runtime();
        const cartridgeSource = '''10 SETP 5 10 1
20 SETP 15 20 1''';
        await runtime.loadCartridge(cartridgeSource);
        expect(runtime.pixelState(5, 10), 1);
        expect(runtime.pixelState(15, 20), 1);
      });
    });
  });
}
