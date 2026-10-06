import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/strings/avoid_join_on_nullable_item_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidJoinOnNullableItemRule', () {
    test('reports join on nullable elements', () async {
      final unit = await resolveSource('''
String combine(List<String?> values) => values.join(',');
''');

      expect(runAnalysisRuleOnUnit(AvoidJoinOnNullableItemRule(), unit), hasLength(1));
    });

    test('does not report join on non-nullable elements', () async {
      final unit = await resolveSource('''
String combine(List<String> values) => values.join(',');
''');

      expect(runAnalysisRuleOnUnit(AvoidJoinOnNullableItemRule(), unit), isEmpty);
    });
  });
}
