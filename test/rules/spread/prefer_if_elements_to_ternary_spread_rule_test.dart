import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/spread/prefer_if_elements_to_ternary_spread_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferIfElementsToTernarySpreadRule', () {
    test('exposes the expected diagnostic code', () {
      expect(PreferIfElementsToTernarySpreadRule().diagnosticCode.name, 'prefer_if_elements_to_ternary_spread');
    });

    test('reports a one-item ternary spread with an empty else branch', () {
      final diagnostics = runAnalysisRule(
        PreferIfElementsToTernarySpreadRule(),
        'void f(bool show, int value) { final values = [...(show ? [value] : [])]; }',
      );

      expect(diagnostics, hasLength(1));
    });

    test('does not report multiple then-items or a non-empty else branch', () {
      final diagnostics = runAnalysisRule(PreferIfElementsToTernarySpreadRule(), '''
void f(bool show) {
  final values = [...(show ? [1, 2] : []), ...(show ? [1] : [2])];
}
''');

      expect(diagnostics, isEmpty);
    });
  });
}
