import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/collections/prefer_where_type_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferWhereTypeRule', () {
    test('reports filtering out null values', () {
      final diagnostics = runAnalysisRule(PreferWhereTypeRule(), '''
Iterable<int> nonNull(Iterable<int?> values) => values.where((value) => value != null);
''');

      expect(diagnostics, hasLength(1));
    });

    test('does not report a predicate unrelated to null checks', () {
      final diagnostics = runAnalysisRule(PreferWhereTypeRule(), '''
Iterable<int> positives(Iterable<int> values) => values.where((value) => value > 0);
''');

      expect(diagnostics, isEmpty);
    });
  });
}
