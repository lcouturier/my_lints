import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/prefer_usage_of_value_getter_rule.dart';

void main() {
  group('PreferVoidCallbackRule metadata', () {
    test('exposes expected diagnostic code', () {
      final rule = PreferUsageOfValueGetterRule();

      expect(rule.diagnosticCode.name, 'prefer_usage_of_value_getter');
      expect(rule.diagnosticCode.problemMessage, 'Prefer using the value getter.');
    });
  });

  group('PreferUsageOfValueGetterRule detection logic', () {
    test('matches a void function type without parameters', () {
      expect(_isReplaceable('class A { void Function() cb; }'), isFalse);
    });

    test('matches a nullable function type', () {
      expect(_isReplaceable('class A { void Function()? cb; }'), isFalse);
    });

    test('does not match the declaration site of a type alias', () {
      expect(_isReplaceable('typedef Cb = void Function();'), isFalse);
    });

    test('does not match a Future return type, no alias exists', () {
      expect(_isReplaceable('class A { Future Function() cb; }'), isTrue);
    });

    test('does not match when the function type has parameters', () {
      expect(_isReplaceable('class A { int Function() cb; }'), isTrue);
    });
  });
}

bool _isReplaceable(String source) {
  final visitor = _FirstGenericFunctionTypeVisitor();
  parseString(content: source).unit.accept(visitor);

  final node = visitor.node;
  if (node == null) {
    throw StateError('No GenericFunctionType found in source: $source');
  }

  return node.isEligibleForValueGetter;
}

class _FirstGenericFunctionTypeVisitor extends RecursiveAstVisitor<void> {
  GenericFunctionType? node;

  @override
  void visitGenericFunctionType(GenericFunctionType node) {
    this.node ??= node;
    super.visitGenericFunctionType(node);
  }
}
