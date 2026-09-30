import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/prefer_first_rule.dart';

void main() {
  group('PreferFirstRule metadata', () {
    test('exposes expected diagnostic code', () {
      final rule = PreferFirstRule();

      expect(rule.diagnosticCode.name, 'prefer_first_over_index');
      expect(rule.diagnosticCode.problemMessage, "Use '.first' instead of accessing the first element by index.");
      expect(rule.diagnosticCode.correctionMessage, "Replace with '.first'.");
    });
  });

  group('isLastElementAccess in index expression', () {
    test('matches a simple identifier receiver', () {
      final expression = _firstIndexExpression('''
void foo() {
  final List<int> list = [1, 2, 3];
  final first = list[0]; // LINT
}
''');
      expect(expression.isFirstElementAccess, true);
    });
  });

  group('isLastElementAccess in method invocation', () {
    test('matches a simple identifier receiver', () {
      final expression = _firstMethodInvocation('''
void bar() {
  final List<int> list = [1, 2, 3];
  final first = list.elementAt(0);
  final second = list[1];
}
''');
      expect(expression.isFirstElementAccess, true);
    });
  });
}

IndexExpression _firstIndexExpression(String source) {
  final parseResult = parseString(content: source);
  final visitor = _Visitor();
  parseResult.unit.accept(visitor);

  final expression = visitor.indexExpression;
  if (expression == null) {
    throw StateError('No IndexExpression found in source: $source');
  }

  return expression;
}

MethodInvocation _firstMethodInvocation(String source) {
  final parseResult = parseString(content: source);
  final visitor = _Visitor();
  parseResult.unit.accept(visitor);

  final expression = visitor.methodInvocation;
  if (expression == null) {
    throw StateError('No MethodInvocation found in source: $source');
  }

  return expression;
}

class _Visitor extends RecursiveAstVisitor<void> {
  IndexExpression? indexExpression;
  MethodInvocation? methodInvocation;

  @override
  void visitIndexExpression(IndexExpression node) {
    indexExpression ??= node;
    super.visitIndexExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    methodInvocation ??= node;
    super.visitMethodInvocation(node);
  }
}
