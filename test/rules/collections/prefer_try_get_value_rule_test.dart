import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/collections/prefer_try_get_value_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferTryGetValueRule metadata', () {
    test('exposes expected diagnostic code', () {
      final rule = PreferTryGetValueRule();

      expect(rule.diagnosticCode.name, 'prefer_try_get_value');
    });
  });

  test('reports containsKey followed by indexing the same map with the same key', () async {
    final unit = await resolveSource('''
Object? lookup(Map<String, Object> values, String key) =>
    values.containsKey(key) ? values[key] : null;
''');

    final diagnostics = runAnalysisRuleOnUnit(PreferTryGetValueRule(), unit);

    expect(diagnostics, hasLength(1));
  });

  test('does not report when the index differs from the containsKey argument', () async {
    final unit = await resolveSource('''
Object? lookup(Map<String, Object> values, String key) =>
    values.containsKey(key) ? values[otherKey] : null;
''');

    final diagnostics = runAnalysisRuleOnUnit(PreferTryGetValueRule(), unit);

    expect(diagnostics, isEmpty);
  });

  test('does not report when the index target differs from the containsKey target', () async {
    final unit = await resolveSource('''
Object? lookup(Map<String, Object> a, Map<String, Object> b, String key) =>
    a.containsKey(key) ? b[key] : null;
''');

    final diagnostics = runAnalysisRuleOnUnit(PreferTryGetValueRule(), unit);

    expect(diagnostics, isEmpty);
  });

  test('does not report conditional expressions without containsKey', () async {
    final unit = await resolveSource('''
int choose(bool condition) => condition ? 1 : 0;
''');

    final diagnostics = runAnalysisRuleOnUnit(PreferTryGetValueRule(), unit);

    expect(diagnostics, isEmpty);
  });
}