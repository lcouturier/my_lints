import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/conditions/avoid_deep_condition_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidDeepConditionsRule', () {
    test('reports a condition deeper than the configured maximum', () {
      final rule = AvoidDeepConditionsRule(maxDepth: 2);
      expect(runAnalysisRule(rule, 'void f(bool a, bool b, bool c) { if (a && b && c) {} }'), hasLength(1));
    });

    test('does not report a condition at the configured maximum', () {
      final rule = AvoidDeepConditionsRule(maxDepth: 5);
      expect(runAnalysisRule(rule, 'void f(bool a, bool b, bool c) { if (a && b && c) {} }'), isEmpty);
    });
  });
}
