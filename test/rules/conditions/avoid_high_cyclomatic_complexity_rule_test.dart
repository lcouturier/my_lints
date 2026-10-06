import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/conditions/avoid_high_cyclomatic_complexity_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidHighCyclomaticComplexityRule', () {
    test('reports a function over the complexity threshold', () {
      final rule = AvoidHighCyclomaticComplexityRule(threshold: 1);
      expect(runAnalysisRule(rule, 'int f(bool condition) { if (condition) return 1; return 0; }'), hasLength(1));
    });

    test('does not report a function at the complexity threshold', () {
      final rule = AvoidHighCyclomaticComplexityRule(threshold: 1);
      expect(runAnalysisRule(rule, 'int f() => 1;'), isEmpty);
    });
  });
}
