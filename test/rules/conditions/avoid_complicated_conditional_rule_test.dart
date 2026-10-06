import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/conditions/avoid_complicated_conditional_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidComplicatedConditionalRule', () {
    test('reports a condition at the configured complexity threshold', () {
      final rule = AvoidComplicatedConditionalRule(threshold: 2);
      final diagnostics = runAnalysisRule(rule, 'void f(bool a, bool b, bool c) { if (a && b && c) {} }');

      expect(diagnostics, hasLength(1));
    });

    test('does not report a condition below the threshold', () {
      final rule = AvoidComplicatedConditionalRule(threshold: 2);
      final diagnostics = runAnalysisRule(rule, 'void f(bool a, bool b) { if (a && b) {} }');

      expect(diagnostics, isEmpty);
    });
  });
}
