import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/collections/prefer_null_aware_elements_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferNullAwareElementsRule', () {
    test('exposes the expected diagnostic code', () {
      expect(PreferNullAwareElementsRule().diagnosticCode.name, 'prefer_null_aware_elements');
    });

    test('reports a null check followed by the same element', () {
      final diagnostics = runAnalysisRule(
        PreferNullAwareElementsRule(),
        '''
void f(List<int>? values) {
  final result = [if (values != null) values];
}
''',
      );

      expect(diagnostics, hasLength(1));
    });

    test('does not report when the checked value differs from the emitted element', () {
      final diagnostics = runAnalysisRule(
        PreferNullAwareElementsRule(),
        '''
void f(List<int>? values, List<int> other) {
  final result = [if (values != null) other];
}
''',
      );

      expect(diagnostics, isEmpty);
    });

    test('does not report when the null check is already using the null-aware element form', () {
      final diagnostics = runAnalysisRule(
        PreferNullAwareElementsRule(),
        '''
void f(List<int>? values) {
  final result = [if (values != null) ...values];
}
''',
      );

      expect(diagnostics, isEmpty);
    });
  });
}
