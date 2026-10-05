import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/collections/prefer_last_rule.dart';

void main() {
  group('PreferLastRule metadata', () {
    test('exposes expected diagnostic code', () {
      final rule = PreferLastRule();

      expect(rule.diagnosticCode.name, 'prefer_last_over_index');
      expect(rule.diagnosticCode.problemMessage, "Use '.last' instead of accessing the last element by index.");
      expect(rule.diagnosticCode.correctionMessage, "Replace with '.last'.");
    });
  });

  group('isLastElementAccess in index expression', () {
    test('matches a simple identifier receiver', () {
      final expression = _firstIndexExpression('''
void bar() {
  final list = [1, 2, 3];
  final first = list[list.length - 1];  
  final second = list[1];  
}
''');
      expect(expression.isLastElementAccess, true);
    });

    test('does not match when accessing a non-last element by index', () {
      final expression = _firstIndexExpression('''
void bar() {
  final list = [1, 2, 3];
  final first = list[list.length - 2];  
  final second = list[1];  
}
''');
      expect(expression.isLastElementAccess, false);
    });
  });

  group('isLastElementAccess in method invocation', () {
    test('matches a simple identifier receiver', () {
      final expression = _firstMethodInvocation('''
void bar() {
  final list = [1, 2, 3];
  final first = list.elementAt(list.length - 1);
  final second = list[1];
}
''');
      expect(expression.isLastElementAccess, true);
    });

    test('does not match when accessing a non-last element by method invocation', () {
      final expression = _firstMethodInvocation('''
void bar() {
  final list = [1, 2, 3];
  final first = list.elementAt(list.length - 2);
  final second = list[1];
}
''');
      expect(expression.isLastElementAccess, false);
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
