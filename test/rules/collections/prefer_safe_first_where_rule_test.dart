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

    test('does not report non-Iterable types', () async {
      final unit = await resolveSource('''
int find(String value) => value.firstWhere((value) => value > 0);
''');

      expect(runAnalysisRuleOnUnit(PreferSafeFirstWhereRule(), unit), isEmpty);
    });

    test('reports singleWhere without orElse', () async {
      final unit = await resolveSource('''
int find(List<int> values) => values.singleWhere((value) => value > 0);
''');

      expect(runAnalysisRuleOnUnit(PreferSafeFirstWhereRule(), unit), hasLength(1));
    });

    test('does not report singleWhere with orElse', () async {
      final unit = await resolveSource('''
int find(List<int> values) => values.singleWhere((value) => value > 0, orElse: () => 0);
''');

      expect(runAnalysisRuleOnUnit(PreferSafeFirstWhereRule(), unit), isEmpty);
    });

    test('reports lastWhere without orElse', () async {
      final unit = await resolveSource('''
int find(List<int> values) => values.lastWhere((value) => value > 0);
''');

      expect(runAnalysisRuleOnUnit(PreferSafeFirstWhereRule(), unit), hasLength(1));
    });

    test('does not report lastWhere with orElse', () async {
      final unit = await resolveSource('''
int find(List<int> values) => values.lastWhere((value) => value > 0, orElse: () => 0);
''');

      expect(runAnalysisRuleOnUnit(PreferSafeFirstWhereRule(), unit), isEmpty);
    });

    test('handles complex expressions', () async {
      final unit = await resolveSource('''
int find(List<int> values) => values.where((value) => value > 0).firstWhere((value) => value > 0);
''');

      expect(runAnalysisRuleOnUnit(PreferSafeFirstWhereRule(), unit), hasLength(1));
    });
  });
}
