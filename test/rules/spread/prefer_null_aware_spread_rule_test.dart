import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/spread/prefer_null_aware_spread_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferNullAwareSpreadRule', () {
    test('exposes the expected diagnostic code', () {
      expect(PreferNullAwareSpreadRule().diagnosticCode.name, 'prefer_null_aware_spread');
    });

    test('reports a null check followed by a spread of the same collection', () {
      final diagnostics = runAnalysisRule(
        PreferNullAwareSpreadRule(),
        'void f(List<int>? values) { final result = [if (values != null) ...values]; }',
      );

      expect(diagnostics, hasLength(1));
    });

    test('does not report mismatched collections or null-aware spreads', () {
      final diagnostics = runAnalysisRule(PreferNullAwareSpreadRule(), '''
void f(List<int>? values, List<int> other) {
  final result = [if (values != null) ...other, ...?values];
}
''');

      expect(diagnostics, isEmpty);
    });
  });
}
