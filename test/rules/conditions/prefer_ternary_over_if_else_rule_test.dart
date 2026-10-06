import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/conditions/prefer_ternary_over_if_else_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferTernaryOverIfElseRule', () {
    test('reports an if-else with simple return expressions', () {
      expect(
        runAnalysisRule(PreferTernaryOverIfElseRule(), 'int f(bool value) { if (value) return 1; else return 0; }'),
        hasLength(1),
      );
    });

    test('does not report an if without an else branch', () {
      expect(
        runAnalysisRule(PreferTernaryOverIfElseRule(), 'int f(bool value) { if (value) return 1; return 0; }'),
        isEmpty,
      );
    });
  });
}
