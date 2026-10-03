import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/avoid_nested_ternary_rule.dart';

import '../rule_test_harness.dart';

void main() {
  group('Avoid Nested Ternary', () {
    test('exposes the expected diagnostic code', () {
      expect(AvoidNestedTernaryRule().diagnosticCode.name, 'avoid_nested_ternary');
    });

    test('reports nested ternary expressions, else expression', () async {
      final unit = await resolveSource('''
void foo() {
  int value = 2;
  String result =
      value >
          0 // LINT
      ? "positive"
      : (value < 0)
      ? "negative"
      : "zero";
  print(result);
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidNestedTernaryRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('reports nested ternary expressions, then expression', () async {
      final unit = await resolveSource('''
void foo() {
  int value = 2;
  String result = (value <= 0) ? (value == 0) ? "zero" : "negative" : "positive";
  print(result);
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidNestedTernaryRule(), unit);

      expect(diagnostics, hasLength(1));
    });
  });
}
