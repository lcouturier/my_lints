import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/collections/avoid_map_keys_contains_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidMapKeysContainsRule metadata', () {
    test('exposes expected diagnostic code', () {
      final rule = AvoidMapKeysContainsRule();

      expect(rule.diagnosticCode.name, 'avoid_map_keys_contains');
      expect(rule.diagnosticCode.problemMessage, 'Avoid using keys.contains for map key checks.');
    });
  });

  group('AvoidMapKeysContainsRule detection logic', () {
    test('does not report a non-keys.contains usage', () async {
      final unit = await resolveSource('''
void f(Map<String, int> myMap) {
    if (myMap.containsKey('key')) { }
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidMapKeysContainsRule(), unit);

      expect(diagnostics, hasLength(0));
    });
    test('reports a keys.contains usage', () async {
      final unit = await resolveSource('''
void f(Map<String, int> myMap) {
    if (myMap.keys.contains('key')) { }
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidMapKeysContainsRule(), unit);

      expect(diagnostics, hasLength(1));
    });
  });
}
