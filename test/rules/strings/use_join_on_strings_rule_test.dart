import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/strings/use_join_on_strings_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('UseJoinOnStringsRule', () {
    test('reports join on an iterable of strings', () async {
      final unit = await resolveSource('''
String combine(List<String> values) => values.join(',');
''');

      expect(runAnalysisRuleOnUnit(UseJoinOnStringsRule(), unit), hasLength(1));
    });

    test('does not report join on an iterable of integers', () async {
      final unit = await resolveSource('''
String combine(List<int> values) => values.join(',');
''');

      expect(runAnalysisRuleOnUnit(UseJoinOnStringsRule(), unit), isEmpty);
    });
  });
}
