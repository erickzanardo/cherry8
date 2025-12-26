const _validVariableNames = [
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
];

const _validOperators = [
  '+',
  '-',
  '*',
  '/',
];

/// {@template unexpected_token_exception}
/// Exception thrown when an incorrect token was found while parsing a token
/// in a berry program.
/// {@endtemplate}
class UnexpectedTokenException implements Exception {
  /// {@macro unexpected_token_exception}
  const UnexpectedTokenException(this.message);

  /// Message
  final String message;

  @override
  String toString() {
    return message;
  }
}

/// {@template program_statement}
/// An abstract representation of a statement in a Berry program.
/// {@endtemplate}
abstract class ProgramStatement {
  /// {@macro program_statement}
  int? execute(BerryLangRuntime runtime);
}

/// {@template program_expression}
/// An abstract representation of a member of a Berry program expression.
/// {@endtemplate}
abstract class ProgramExpressionMember {
  /// Evaluates the member and returns its integer value.
  int evaluate(BerryLangRuntime runtime);
}

/// {@template operation_expression_member}
/// A member of a Berry program expression that represents an operation
/// between two other expression members.
/// {@endtemplate}
class OperationExpressionMember extends ProgramExpressionMember {
  /// {@macro operation_expression_member}
  OperationExpressionMember({
    required this.operator,
    required this.left,
    required this.right,
  });

  /// Operator
  final String operator;

  /// Left operand
  final ProgramExpressionMember left;

  /// Right operand
  final ProgramExpressionMember right;

  @override
  int evaluate(BerryLangRuntime runtime) {
    final leftValue = left.evaluate(runtime);
    final rightValue = right.evaluate(runtime);

    switch (operator) {
      case '+':
        return leftValue + rightValue;
      case '-':
        return leftValue - rightValue;
      case '*':
        return leftValue * rightValue;
      case '/':
        return leftValue ~/ rightValue;
      default:
        throw UnexpectedTokenException('Invalid operator: $operator');
    }
  }
}

/// {@template literal_expression_member}
/// A member of a Berry program expression that represents a literal integer
/// value.
/// {@endtemplate}
class LiteralExpressionMember extends ProgramExpressionMember {
  /// {@macro literal_expression_member}
  LiteralExpressionMember(this.value);

  /// {@macro literal_expression_member}
  final int value;

  @override
  int evaluate(BerryLangRuntime runtime) => value;
}

/// {@template variable_expression_member}
/// A member of a Berry program expression that represents a variable.
/// {@endtemplate}
class VariableExpressionMember extends ProgramExpressionMember {
  /// {@macro variable_expression_member}
  VariableExpressionMember(this.name);

  /// {@macro variable_expression_member}
  final String name;

  @override
  int evaluate(BerryLangRuntime runtime) => runtime.getVariable(name);
}

/// Abstraction for an expression.
/// An expression is part of a statement that will compute a value
///
/// It is composed of members like operations and values which are used
/// to make such computation.
class ProgramExpression {
  /// {@macro program_expression}
  ProgramExpression(this.members);

  /// {@macro program_expression}
  factory ProgramExpression.fromTokens(List<String> tokens) {
    final members = <ProgramExpressionMember>[];

    final rawTokens = List<String>.from(tokens);

    ProgramExpressionMember? parseBasicMember(String token) {
      if (_validVariableNames.contains(token)) {
        return VariableExpressionMember(token);
      } else if (int.tryParse(token) != null) {
        return LiteralExpressionMember(int.parse(token));
      } else {
        return null;
      }
    }

    while (rawTokens.isNotEmpty) {
      final t = rawTokens.removeAt(0);

      final basicMember = parseBasicMember(t);
      if (basicMember != null) {
        members.add(basicMember);
      } else if (_validOperators.contains(t)) {
        if (members.isEmpty) {
          throw UnexpectedTokenException('Operator $t has no left operand');
        }

        final left = members.removeLast();
        if (rawTokens.isEmpty) {
          throw UnexpectedTokenException('Operator $t has no right operand');
        }

        final rightToken = rawTokens.removeAt(0);
        final right = parseBasicMember(rightToken);
        if (right == null) {
          throw UnexpectedTokenException('Invalid right operand: $rightToken');
        }

        members.add(
          OperationExpressionMember(
            operator: t,
            left: left,
            right: right,
          ),
        );
      } else {
        throw UnexpectedTokenException('Invalid expression token: $t');
      }
    }

    return ProgramExpression(members.toList());
  }

  /// Members from this expression.
  final List<ProgramExpressionMember> members;

  /// Evaluates the expression and returns its integer value.
  int evaluate(BerryLangRuntime runtime) {
    // For now, only support single literal values
    if (members.length != 1) {
      throw const UnexpectedTokenException(
        'Only single literal expressions are supported for now',
      );
    }

    return members.first.evaluate(runtime);
  }
}

/// {@template let_statement}
/// A Statement that will assign a value to a variable in the runtime.
/// {@endtemplate}
class LetStatement extends ProgramStatement {
  /// {@macro let_statement}
  LetStatement({
    required this.variable,
    required this.expresion,
  });

  /// {@macro let_statement}
  factory LetStatement.fromTokens(List<String> tokens) {
    final variable = tokens.first;
    if (!_validVariableNames.contains(variable)) {
      throw UnexpectedTokenException('Invalid variable name: $variable');
    }
    if (tokens[1] != '=') {
      throw const UnexpectedTokenException('Expected "=" after variable name');
    }

    final expressionTokens = tokens.sublist(2);
    final expression = ProgramExpression.fromTokens(expressionTokens);
    return LetStatement(
      variable: variable,
      expresion: expression,
    );
  }

  /// The target variable
  final String variable;

  /// The expression that will compute the value
  final ProgramExpression expresion;

  @override
  int? execute(BerryLangRuntime runtime) {
    final value = expresion.evaluate(runtime);
    runtime._variables[variable] = value;
    return null;
  }
}

/// {@template program_line}
/// A line in a Berry program consisting of a line number and a statement.
/// {@endtemplate}
class ProgramLine {
  /// {@macro program_line}
  ProgramLine(this.number, this.statement);

  /// {@macro program_line}
  factory ProgramLine.fromString(String line) {
    final tokens = line.split(' ');

    if (tokens.length < 2) {
      throw UnexpectedTokenException('Invalid line: $line');
    }

    final [lineNumberStr, statementStr, ...rest] = tokens;

    final lineNumber = int.tryParse(lineNumberStr);
    if (lineNumber == null) {
      throw UnexpectedTokenException(
        'Invalid line number: $lineNumberStr at line $line',
      );
    }

    late ProgramStatement statement;
    if (statementStr == 'LET') {
      statement = LetStatement.fromTokens(rest);
    } else {
      throw UnexpectedTokenException(
        'Unknow command: $statementStr at line $line',
      );
    }

    return ProgramLine(lineNumber, statement);
  }

  /// The line number.
  final int number;

  /// The statement associated with the line.
  final ProgramStatement statement;
}

/// {@template berry_lang_runtime}
/// Berry Language Runtime
/// {@endtemplate}
class BerryLangRuntime {
  /// {@macro berry_lang_runtime}
  BerryLangRuntime();

  final Map<String, int> _variables = {};
  final Map<int, ProgramLine> _lines = {};

  var pc = 0;

  /// Returns the line for the given line number
  ProgramLine? getLine(int line) => _lines[line];

  /// Gets the value of a variable by its name.
  int getVariable(String name) => _variables[name] ?? 0;

  /// Loads a Berry program from the given source code into memory.
  void loadProgram(String source) {
    final stringLines = source.split('\n');

    final programLines = stringLines.map(ProgramLine.fromString);

    for (final l in programLines) {
      _lines[l.number] = l;
    }
  }

  /// Runs the program
  Future<void> runProgram() async {
    final allLines = _lines.keys.toList()..sort();

    pc = 0;
    while (pc < allLines.length) {
      final lineNumber = allLines[pc];
      final line = _lines[lineNumber]!;

      final newPc = line.statement.execute(this);
      if (newPc != null) {
        pc = allLines.indexOf(newPc);
      } else {
        pc++;
      }
    }
  }
}
