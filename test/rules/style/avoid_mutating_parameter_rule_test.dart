import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/style/avoid_mutating_parameter_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidMutatingParametersRule', () {
    test('reports assigning to a parameter', () async {
      final unit = await resolveSource('void update(int value) { value = 2; }');
      expect(runAnalysisRuleOnUnit(AvoidMutatingParametersRule(), unit), hasLength(1));
    });

    test('does not report when the parameter is unchanged', () async {
      final unit = await resolveSource('int update(int value) => value + 1;');
      expect(runAnalysisRuleOnUnit(AvoidMutatingParametersRule(), unit), isEmpty);
    });
  });
}
