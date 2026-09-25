import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/prefer_void_callback_rule.dart';

void main() {
  group('PreferVoidCallbackRule metadata', () {
    test('exposes expected diagnostic code', () {
      final rule = PreferVoidCallbackRule();

      expect(rule.diagnosticCode.name, 'prefer_void_callback');
      expect(rule.diagnosticCode.problemMessage, 'Prefer VoidCallback over void Function()');
    });
  });

  group('PreferVoidCallbackRule detection logic', () {
    test('matches a void function type without parameters', () {
      expect(_isReplaceable('class A { void Function() cb; }'), isTrue);
    });

    test('matches a nullable function type', () {
      expect(_isReplaceable('class A { void Function()? cb; }'), isTrue);
    });

    test('matches a non-void return type, replaceable by ValueGetter', () {
      expect(_isReplaceable('class A { int Function() cb; }'), isTrue);
    });

    test('does not match the declaration site of a type alias', () {
      expect(_isReplaceable('typedef Cb = void Function();'), isFalse);
    });

    test('does not match a Future return type, no alias exists', () {
      expect(_isReplaceable('class A { Future Function() cb; }'), isFalse);
    });

    test('does not match when the function type has parameters', () {
      expect(_isReplaceable('class A { void Function(int) cb; }'), isFalse);
    });

    test('does not match when the function type is generic', () {
      expect(_isReplaceable('class A { void Function<T>() cb; }'), isFalse);
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

  return node.isReplaceableByCallbackAlias;
}

class _FirstGenericFunctionTypeVisitor extends RecursiveAstVisitor<void> {
  GenericFunctionType? node;

  @override
  void visitGenericFunctionType(GenericFunctionType node) {
    this.node ??= node;
    super.visitGenericFunctionType(node);
  }
}
