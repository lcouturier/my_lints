import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/common/extensions.dart';
import 'package:my_lints/src/rules/avoid_yoda_condition_rule.dart';

void main() {
  group('AvoidYodaConditionsRule metadata', () {
    test('exposes expected diagnostic code', () {
      final rule = AvoidYodaConditionsRule();

      expect(rule.diagnosticCode.name, 'avoid_yoda_conditions');
      expect(rule.diagnosticCode.problemMessage, 'Avoid Yoda conditions.');
      expect(rule.diagnosticCode.correctionMessage, 'Consider reordering the operands to improve readability.');
    });
  });

  group('AvoidYodaConditionsRule detection logic', () {
    test('matches when left side is a constant and right side is not', () {
      final expression = _firstBinaryExpression('void f(int value) { if (1 == value) {} }');

      expect(_matchesRule(expression), isTrue);
    });

    test('matches in do/while condition', () {
      final expression = _firstBinaryExpression('void f(int value) { do {} while (0 != value); }');

      expect(_matchesRule(expression), isTrue);
    });

    test('matches in ternary condition', () {
      final expression = _firstBinaryExpression('int f(int value) => 0 == value ? 1 : 2;');

      expect(_matchesRule(expression), isTrue);
    });

    test('does not match when variable is on the left', () {
      final expression = _firstBinaryExpression('void f(int value) { if (value == 1) {} }');

      expect(_matchesRule(expression), isFalse);
    });

    test('does not match when both sides are constants', () {
      final expression = _firstBinaryExpression('void f() { if (1 == 2) {} }');

      expect(_matchesRule(expression), isFalse);
    });

    test('does not match non-comparison operator', () {
      final expression = _firstBinaryExpression('void f(int value) { if (1 + value > 0) {} }');

      expect(_matchesRule(expression), isFalse);
    });
  });
}

bool _matchesRule(BinaryExpression node) {
  return node.operator.type.isComparisonOperator && node.leftOperand.isConstant && !node.rightOperand.isConstant;
}

BinaryExpression _firstBinaryExpression(String source) {
  final parseResult = parseString(content: source);
  final visitor = _FirstBinaryExpressionVisitor();
  parseResult.unit.accept(visitor);

  final expression = visitor.expression;
  if (expression == null) {
    throw StateError('No BinaryExpression found in source: $source');
  }

  return expression;
}

class _FirstBinaryExpressionVisitor extends RecursiveAstVisitor<void> {
  BinaryExpression? expression;

  @override
  void visitBinaryExpression(BinaryExpression node) {
    expression ??= node;
    super.visitBinaryExpression(node);
  }
}
