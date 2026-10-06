import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/conditions/no_boolean_compare_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('NoBooleanLiteralCompareRule', () {
    test('reports comparing a non-nullable boolean to a literal', () async {
      final unit = await resolveSource('''
bool enabled = true;
final result = enabled == true;
''');

      expect(runAnalysisRuleOnUnit(NoBooleanLiteralCompareRule(), unit), hasLength(1));
    });

    test('does not report comparing two boolean variables', () async {
      final unit = await resolveSource('''
bool enabled = true;
bool visible = false;
final result = enabled == visible;
''');

      expect(runAnalysisRuleOnUnit(NoBooleanLiteralCompareRule(), unit), isEmpty);
    });
  });
}
