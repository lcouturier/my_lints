import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/collections/prefer_safe_first_where_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferSafeFirstWhereRule', () {
    test('reports firstWhere without orElse', () async {
      final unit = await resolveSource('''
int find(List<int> values) => values.firstWhere((value) => value > 0);
''');

      expect(runAnalysisRuleOnUnit(PreferSafeFirstWhereRule(), unit), hasLength(1));
    });

    test('does not report firstWhere with orElse', () async {
      final unit = await resolveSource('''
int find(List<int> values) => values.firstWhere((value) => value > 0, orElse: () => 0);
''');

      expect(runAnalysisRuleOnUnit(PreferSafeFirstWhereRule(), unit), isEmpty);
    });
  });
}
