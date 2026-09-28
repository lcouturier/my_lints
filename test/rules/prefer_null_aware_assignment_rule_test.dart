import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/prefer_null_aware_assignment_rule.dart';

void main() {
  group('PreferVoidCallbackRule metadata', () {
    test('exposes expected diagnostic code', () {
      final rule = PreferNullAwareAssignmentRule();

      expect(rule.diagnosticCode.name, 'prefer_null_aware_assignment');
      expect(rule.diagnosticCode.correctionMessage, 'Use ??= instead of explicit null check and assignment.');
    });
  });

  group('PreferNullAwareAssignmentRule detection logic', () {
    test('matches a void function type without parameters', () {
      expect(
        _isReplaceable('''
void f(int? a)
{
  if (a == null) {
    a = 42;
  }
}
      '''),
        isTrue,
      );
    });

    test('matches a void function type without parameters', () {
      expect(
        _isReplaceable('''
void f(int? a)
{
  if (a == null) {
    a = 42;
  } else {
    a = 10;
  }
}
      '''),
        isFalse,
      );
    });
  });
}

bool _isReplaceable(String source) {
  final visitor = _NullAwareAssignmentVisitor();
  parseString(content: source).unit.accept(visitor);

  final node = visitor.node;
  if (node == null) {
    throw StateError('No GenericFunctionType found in source: $source');
  }

  return node.isReplacable;
}

class _NullAwareAssignmentVisitor extends RecursiveAstVisitor<void> {
  IfStatement? node;

  @override
  void visitIfStatement(IfStatement node) {
    this.node ??= node;
    super.visitIfStatement(node);
  }
}
