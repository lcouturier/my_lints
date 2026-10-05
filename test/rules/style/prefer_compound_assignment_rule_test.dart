import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/style/prefer_compound_assignment_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferCompoundAssignmentRule metadata', () {
    test('exposes expected diagnostic code', () {
      final rule = PreferCompoundAssignmentRule();

      expect(rule.diagnosticCode.name, 'prefer_compound_assignment');
      expect(
        rule.diagnosticCode.problemMessage,
        'Prefer using compound assignment operators (e.g., +=, -=) instead of simple assignment with arithmetic operations.',
      );
    });
  });

  group('PreferCompoundAssignmentRule', () {
    test('reports when simple assignment is used with arithmetic operations', () async {
      final unit = await resolveSource('''
void foo() {
  int x = 5;
  x = x + 1; // This should be reported by the rule.
  print(x);
}
''');
      final diagnostics = runAnalysisRuleOnUnit(PreferCompoundAssignmentRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('reports when simple assignment is used with arithmetic operations', () async {
      final unit = await resolveSource('''
void foo() {
  int x = 5;
  x =+ 1;
  print(x);
}
''');
      final diagnostics = runAnalysisRuleOnUnit(PreferCompoundAssignmentRule(), unit);

      expect(diagnostics, isEmpty);
    });
  });
}
