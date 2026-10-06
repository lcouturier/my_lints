import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/conditions/avoid_double_negation_conditions_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidDoubleNegationConditionsRule', () {
    test('reports negation of an already negative name', () {
      expect(
        runAnalysisRule(AvoidDoubleNegationConditionsRule(), 'bool f(bool isDisabled) => !isDisabled;'),
        hasLength(1),
      );
    });

    test('does not report negation of a positive name', () {
      expect(runAnalysisRule(AvoidDoubleNegationConditionsRule(), 'bool f(bool isEnabled) => !isEnabled;'), isEmpty);
    });
  });
}
