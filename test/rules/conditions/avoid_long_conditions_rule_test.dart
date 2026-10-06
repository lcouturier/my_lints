import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/conditions/avoid_long_conditions_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidLongConditionsRule', () {
    test('reports a condition exceeding a configured metric', () {
      final rule = AvoidLongConditionsRule(maxTokens: 0, maxVariables: 10, maxOperatorTypes: 10);
      expect(runAnalysisRule(rule, 'void f(bool a, bool b) { if (a && b) {} }'), hasLength(1));
    });

    test('does not report a condition within all configured metrics', () {
      final rule = AvoidLongConditionsRule(maxTokens: 100, maxVariables: 10, maxOperatorTypes: 10);
      expect(runAnalysisRule(rule, 'void f(bool a) { if (a) {} }'), isEmpty);
    });
  });
}
