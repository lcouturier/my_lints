import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/style/avoid_ignoring_return_values_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidIgnoringReturnValuesRule', () {
    test('reports an ignored non-void return value', () async {
      final unit = await resolveSource('''
int calculate() => 1;
void run() { calculate(); }
''');

      expect(runAnalysisRuleOnUnit(AvoidIgnoringReturnValuesRule(), unit), hasLength(1));
    });

    test('does not report an ignored void return value', () async {
      final unit = await resolveSource('''
void save() {}
void run() { save(); }
''');

      expect(runAnalysisRuleOnUnit(AvoidIgnoringReturnValuesRule(), unit), isEmpty);
    });
  });
}
