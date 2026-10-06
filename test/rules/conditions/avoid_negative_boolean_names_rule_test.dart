import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/conditions/avoid_negative_boolean_names_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidNegativeBooleanRule', () {
    test('reports a negatively named boolean declaration and parameter', () async {
      final unit = await resolveSource('''
void update(bool isDisabled) {
  bool hasNoValue = false;
}
''');

      expect(runAnalysisRuleOnUnit(AvoidNegativeBooleanRule(), unit), hasLength(2));
    });

    test('does not report positive boolean names', () async {
      final unit = await resolveSource('''
void update(bool isEnabled) {
  bool hasValue = true;
}
''');

      expect(runAnalysisRuleOnUnit(AvoidNegativeBooleanRule(), unit), isEmpty);
    });
  });
}
