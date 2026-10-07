import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/strings/avoid_tolist_before_join_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidToListBeforeJoinRule', () {
    test('reports converting an iterable to a list before join', () async {
      final unit = await resolveSource('''
String combine(Iterable<String> values) => values.toList().join(',');
''');

      expect(runAnalysisRuleOnUnit(AvoidToListBeforeJoinRule(), unit), hasLength(1));
    });

    test('does not report joining an iterable directly', () async {
      final unit = await resolveSource('''
String combine(Iterable<String> values) => values.join(',');
''');

      expect(runAnalysisRuleOnUnit(AvoidToListBeforeJoinRule(), unit), isEmpty);
    });

    test('does not report joining a list', () async {
      final unit = await resolveSource('''
String combine(List<String> values) => values.join(',');
''');
      expect(runAnalysisRuleOnUnit(AvoidToListBeforeJoinRule(), unit), isEmpty);
    });
  });
}
