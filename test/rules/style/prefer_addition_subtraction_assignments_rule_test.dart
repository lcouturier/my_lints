import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/style/prefer_addition_subtraction_assignments_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferAdditionSubtractionAssignmentsRule metadata', () {
    test('exposes expected diagnostic code', () {
      final rule = PreferAdditionSubtractionAssignmentsRule();

      expect(rule.diagnosticCode.name, 'prefer_addition_subtraction_assignments');
      expect(rule.diagnosticCode.problemMessage, 'Prefer using += and -= instead of ++ and --');
    });
  });

  group('PreferAdditionSubtractionAssignmentsRule', () {
    test('reports when simple assignment is used with arithmetic operations', () async {
      final unit = await resolveSource('''
void main() {
  int x = 5;
  x++; // This will be reported by the rule.
  x--; // This will also be reported by the rule.
}
''');
      final diagnostics = runAnalysisRuleOnUnit(PreferAdditionSubtractionAssignmentsRule(), unit);

      expect(diagnostics, hasLength(2));
    });

    test('does not report when compound assignment is used', () async {
      final unit = await resolveSource('''
void main() {
  int x = 5;
  x += 1; // This will not be reported by the rule.
  x -= 1; // This will not be reported by the rule.
}
''');
      final diagnostics = runAnalysisRuleOnUnit(PreferAdditionSubtractionAssignmentsRule(), unit);

      expect(diagnostics, isEmpty);
    });
  });
}
