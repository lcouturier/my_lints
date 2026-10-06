import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/collections/prefer_const_empty_list_after_if_null_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferConstEmptyListAfterIfNullRule', () {
    test('reports a mutable empty-list fallback', () {
      expect(
        runAnalysisRule(PreferConstEmptyListAfterIfNullRule(), 'List<int>? values; final result = values ?? [];'),
        hasLength(1),
      );
    });

    test('does not report a const empty-list fallback', () {
      expect(
        runAnalysisRule(PreferConstEmptyListAfterIfNullRule(), 'List<int>? values; final result = values ?? const [];'),
        isEmpty,
      );
    });
  });
}
