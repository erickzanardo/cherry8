import 'package:cherry_8_flutter_runtime/cherry_8_flutter_runtime.dart';
import 'package:flutter/material.dart';

const cartridgeCode = '''10 RMAIN 20
20 LET X = X + 1
30 SETP X 10 1''';

void main() {
  runApp(Cherry8GameView(cartridgeCode: cartridgeCode));
}
