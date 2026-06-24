// ignore_for_file: unused_import, unused_element

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/avoid_yoda_condition_rule.dart';

void main() {
  // group('isYodaComparison', () {
  //   test('returns true when left side is a literal', () {
  //     final expression = _firstBinaryExpression('void f(int value) { if (1 == value) {} }');
  //     expect(isYodaComparison(expression), isTrue);
  //   });

  //   test('returns true when left side is a negative literal', () {
  //     final expression = _firstBinaryExpression('void f(int value) { while (-1 == value) {} }');
  //     expect(isYodaComparison(expression), isTrue);
  //   });

  //   test('returns false when right side is a literal', () {
  //     final expression = _firstBinaryExpression('void f(int value) { if (value == 1) {} }');
  //     expect(isYodaComparison(expression), isFalse);
  //   });

  //   test('returns false when both sides are literals', () {
  //     final expression = _firstBinaryExpression('void f() { if (1 == 2) {} }');
  //     expect(isYodaComparison(expression), isFalse);
  //   });

  //   test('returns false for non-comparison operators', () {
  //     final expression = _firstBinaryExpression('void f(int value) { if ((1 + value) > 0) {} }');
  //     expect(isYodaComparison(expression), isFalse);
  //   });
  // });
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
