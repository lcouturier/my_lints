import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/common/extensions.dart';
import 'package:my_lints/src/rules/prefer_is_empty_rule.dart';

void main() {
  group('PreferIsEmptyRule metadata', () {
    test('exposes expected diagnostic code', () {
      final rule = PreferIsEmptyRule();

      expect(rule.diagnosticCode.name, 'prefer_is_empty');
      expect(
        rule.diagnosticCode.problemMessage,
        'Prefer using `isEmpty`/`isNotEmpty` instead of comparing `length` to `0`.',
      );
      expect(
        rule.diagnosticCode.correctionMessage,
        'Replace `.length == 0` with `.isEmpty` and `.length != 0` with `.isNotEmpty`.',
      );
    });
  });

  group('lengthComparisonTarget', () {
    test('matches a simple identifier receiver', () {
      final expression = _firstBinaryExpression('void f(List<int> list) { if (list.length == 0) {} }');

      expect(expression.lengthComparisonTarget?.toSource(), 'list');
    });

    test('matches a nested property access receiver', () {
      final expression = _firstBinaryExpression('void f(dynamic a) { if (a.b.length == 0) {} }');

      expect(expression.lengthComparisonTarget?.toSource(), 'a.b');
    });

    test('matches a method invocation receiver', () {
      final expression = _firstBinaryExpression('void f() { if (items().length != 0) {} }');

      expect(expression.lengthComparisonTarget?.toSource(), 'items()');
    });

    test('matches an index expression receiver', () {
      final expression = _firstBinaryExpression('void f(List<String> l) { if (l[0].length == 0) {} }');

      expect(expression.lengthComparisonTarget?.toSource(), 'l[0]');
    });

    test('keeps parentheses of a parenthesized receiver', () {
      final expression = _firstBinaryExpression('void f(Object o) { if ((o as List).length == 0) {} }');

      expect(expression.lengthComparisonTarget?.toSource(), '(o as List)');
    });

    test('matches a string literal receiver', () {
      final expression = _firstBinaryExpression("void f() { if ('abc'.length == 0) {} }");

      expect(expression.lengthComparisonTarget?.toSource(), "'abc'");
    });

    test('does not match a comparison to a non-zero literal', () {
      final expression = _firstBinaryExpression('void f(List<int> list) { if (list.length == 1) {} }');

      expect(expression.lengthComparisonTarget, isNull);
    });

    test('does not match a relational operator', () {
      final expression = _firstBinaryExpression('void f(List<int> list) { if (list.length > 0) {} }');

      expect(expression.lengthComparisonTarget, isNull);
    });

    test('does not match another property than length', () {
      final expression = _firstBinaryExpression('void f(dynamic list) { if (list.size == 0) {} }');

      expect(expression.lengthComparisonTarget, isNull);
    });

    test('does not match a yoda comparison', () {
      final expression = _firstBinaryExpression('void f(List<int> list) { if (0 == list.length) {} }');

      expect(expression.lengthComparisonTarget, isNull);
    });
  });

  group('emptinessGetterName', () {
    test('returns isEmpty for ==', () {
      final expression = _firstBinaryExpression('void f(List<int> list) { if (list.length == 0) {} }');

      expect(expression.emptinessGetterName, 'isEmpty');
    });

    test('returns isNotEmpty for !=', () {
      final expression = _firstBinaryExpression('void f(List<int> list) { if (list.length != 0) {} }');

      expect(expression.emptinessGetterName, 'isNotEmpty');
    });
  });
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
