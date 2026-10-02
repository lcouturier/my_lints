import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/spread/prefer_null_aware_spread_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferNullAwareSpreadRule', () {
    test('reports a null check followed by a spread of the same collection', () {
      final diagnostics = runAnalysisRule(PreferNullAwareSpreadRule(), '''
final collection = [
    if (localSet != null) ...localSet,
    ...localSet != null ? localSet : <String>{},
    ...localSet ?? {},
    ...{localSet == null ? {} : localSet},
    ...{localSet != null ? localSet : {}},
  ];''');

      expect(diagnostics, hasLength(5));
    });

    test('exposes the expected diagnostic code', () {
      expect(PreferNullAwareSpreadRule().diagnosticCode.name, 'prefer_null_aware_spread');
    });

    test('does not report mismatched collections or null-aware spreads', () {
      final diagnostics = runAnalysisRule(PreferNullAwareSpreadRule(), '''
void f(List<int>? values, List<int> other) {
  final result = [...other, ...?values];
}
''');

      expect(diagnostics, isEmpty);
    });
  });
}
