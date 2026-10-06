import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/collections/prefer_try_get_value_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferTryGetValueRule', () {
    test('reports containsKey followed by indexing with a computed key', () {
      final diagnostics = runAnalysisRule(PreferTryGetValueRule(), '''
Object? lookup(Map<String, Object> values, String key) =>
    values.containsKey(key) ? values[key + ''] : null;
''');

      expect(diagnostics, hasLength(1));
    });

    test('does not report unrelated conditional expressions', () {
      final diagnostics = runAnalysisRule(PreferTryGetValueRule(), '''
int choose(bool condition) => condition ? 1 : 0;
''');

      expect(diagnostics, isEmpty);
    });
  });
}
