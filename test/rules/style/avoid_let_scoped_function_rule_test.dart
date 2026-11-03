import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/style/avoid_let_scoped_function_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidLetScopedFunctionRule', () {
    test('exposes the expected diagnostic metadata', () {
      expect(AvoidLetScopedFunctionRule.code.name, 'avoid_let_scoped_function');
      expect(AvoidLetScopedFunctionRule.code.problemMessage, 'Avoid using let before the if-null operator.');
      expect(
        AvoidLetScopedFunctionRule.code.correctionMessage,
        'Use a null-aware expression before the fallback value.',
      );
    });

    test('registers a binary expression processor', () {
      expect(registeredNodeTypes(AvoidLetScopedFunctionRule()), {'BinaryExpression'});
    });

    test('reports let followed by a fallback value', () {
      final diagnostics = runAnalysisRule(
        AvoidLetScopedFunctionRule(),
        "final result = name.let((it) => it.toUpperCase()) ?? '';",
      );

      expect(diagnostics, hasLength(1));
    });

    test('reports a parenthesized let call followed by a fallback value', () {
      final diagnostics = runAnalysisRule(
        AvoidLetScopedFunctionRule(),
        "final result = ((name.let((it) => it.toUpperCase()))) ?? '';",
      );

      expect(diagnostics, hasLength(1));
    });

    test('does not report let without a fallback value', () {
      expect(
        runAnalysisRule(AvoidLetScopedFunctionRule(), 'final result = name.let((it) => it.toUpperCase());'),
        isEmpty,
      );
    });

    test('does not report another call followed by a fallback value', () {
      expect(runAnalysisRule(AvoidLetScopedFunctionRule(), "final result = name.trim() ?? '';"), isEmpty);
    });

    test('does not report let outside the left operand', () {
      expect(
        runAnalysisRule(AvoidLetScopedFunctionRule(), "final result = name ?? fallback.let((it) => it.trim());"),
        isEmpty,
      );
    });
  });
}
