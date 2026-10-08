import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/collections/prefer_null_aware_notation_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferNullAwareNotationRule', () {
    test('reports comparing a nullable boolean with true', () async {
      final unit = await resolveSource('''
bool? isReady;
final ready = isReady == true;
''');

      expect(runAnalysisRuleOnUnit(PreferNullAwareNotationRule(), unit), hasLength(1));
    });

    test('does not report a non-nullable boolean comparison', () async {
      final unit = await resolveSource('''
bool isReady = false;
final ready = isReady == true;
''');

      expect(runAnalysisRuleOnUnit(PreferNullAwareNotationRule(), unit), isEmpty);
    });

    test('reports comparing a nullable boolean with false', () async {
      final unit = await resolveSource('''
bool? isReady;
final ready = isReady == false;
''');

      expect(runAnalysisRuleOnUnit(PreferNullAwareNotationRule(), unit), hasLength(1));
    });

    test('reports comparing a nullable boolean with != true', () async {
      final unit = await resolveSource('''
bool? isReady;
final ready = isReady != true;
''');

      expect(runAnalysisRuleOnUnit(PreferNullAwareNotationRule(), unit), hasLength(1));
    });

    test('reports comparing a nullable boolean with != false', () async {
      final unit = await resolveSource('''
bool? isReady;
final ready = isReady != false;
''');

      expect(runAnalysisRuleOnUnit(PreferNullAwareNotationRule(), unit), hasLength(1));
    });
  });
}
