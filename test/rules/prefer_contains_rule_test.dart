import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/prefer_contains_rule.dart';

void main() {
  group('PreferContainsRule metadata', () {
    test('exposes expected diagnostic code', () {
      final rule = PreferContainsRule();

      expect(rule.diagnosticCode.name, 'prefer_contains_over_indexOf');
      expect(rule.diagnosticCode.problemMessage, 'Use .contains() instead of .indexOf() compared to -1.');
      expect(rule.diagnosticCode.correctionMessage, 'Replace with .contains() for better readability.');
    });
  });

  group('isIndexOfComparedToMinusOne', () {
    test('matches equality comparison', () {
      final expression = _firstBinaryExpression('''
void bar(List<int> values, int value) {
  final isMissing = values.indexOf(value) == -1;
}
''');

      expect(expression.isIndexOfComparedToMinusOne, isTrue);
    });

    test('matches inequality comparison', () {
      final expression = _firstBinaryExpression('''
void bar(List<int> values, int value) {
  final isPresent = values.indexOf(value) != -1;
}
''');

      expect(expression.isIndexOfComparedToMinusOne, isTrue);
    });

    test('does not match a different comparison value', () {
      final expression = _firstBinaryExpression('''
void bar(List<int> values, int value) {
  final isAtFirstPosition = values.indexOf(value) == 0;
}
''');

      expect(expression.isIndexOfComparedToMinusOne, isFalse);
    });

    test('does not match a different method', () {
      final expression = _firstBinaryExpression('''
void bar(List<int> values, int value) {
  final result = values.contains(value) == -1;
}
''');

      expect(expression.isIndexOfComparedToMinusOne, isFalse);
    });
  });
}

BinaryExpression _firstBinaryExpression(String source) {
  final parseResult = parseString(content: source);
  final visitor = _Visitor();
  parseResult.unit.accept(visitor);

  final expression = visitor.binaryExpression;
  if (expression == null) {
    throw StateError('No BinaryExpression found in source: $source');
  }

  return expression;
}

class _Visitor extends RecursiveAstVisitor<void> {
  BinaryExpression? binaryExpression;

  @override
  void visitBinaryExpression(BinaryExpression node) {
    binaryExpression ??= node;
    super.visitBinaryExpression(node);
  }
}
