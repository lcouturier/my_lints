import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/common/extensions.dart';
import 'package:my_lints/src/rules/avoid_yoda_condition_rule.dart';

import '../rule_test_harness.dart';

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
    test('registers every supported condition host', () {
      expect(
        registeredNodeTypes(AvoidYodaConditionsRule()),
        containsAll(['IfStatement', 'WhileStatement', 'DoStatement', 'ForStatement', 'ConditionalExpression']),
      );
    });

    test('reports constants on the left in if, loop, and conditional expressions', () {
      final diagnostics = runAnalysisRule(AvoidYodaConditionsRule(), '''
void f(int value) {
  if (1 == value) {}
  while (2 == value) {}
  do {} while (3 != value);
  for (; 4 != value;) { break; }
  final result = 5 == value ? 1 : 2;
}
''');

      expect(diagnostics, hasLength(5));
    });

    test('reports constants on the left in while and for loop conditions', () {
      final diagnostics = runAnalysisRule(AvoidYodaConditionsRule(), '''
void f(int value) {
  while (2 == value) {}
  for (; 4 != value;) { break; }
}
''');

      expect(diagnostics, hasLength(2));
    });

    test('does not report variables on the left or two constants', () {
      final diagnostics = runAnalysisRule(
        AvoidYodaConditionsRule(),
        'void f(int value) { if (value == 1) {} if (1 == 2) {} }',
      );

      expect(diagnostics, isEmpty);
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
