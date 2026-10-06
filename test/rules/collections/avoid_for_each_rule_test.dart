import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/collections/avoid_for_each_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidForEachRule', () {
    test('reports forEach on a list', () async {
      final unit = await resolveSource('''
void process(List<int> values) {
  values.forEach((value) {});
}
''');

      expect(runAnalysisRuleOnUnit(AvoidForEachRule(), unit), hasLength(1));
    });

    test('does not report a for-in loop', () async {
      final unit = await resolveSource('''
void process(List<int> values) {
  for (final value in values) {
    print(value);
  }
}
''');

      expect(runAnalysisRuleOnUnit(AvoidForEachRule(), unit), isEmpty);
    });
  });
}
