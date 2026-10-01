import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/prefer_null_aware_assignment_rule.dart';

import '../rule_test_harness.dart';

void main() {
  group('PreferNullAwareAssignmentRule', () {
    test('exposes the expected diagnostic code', () {
      final rule = PreferNullAwareAssignmentRule();

      expect(rule.diagnosticCode.name, 'prefer_null_aware_assignment');
      expect(rule.diagnosticCode.correctionMessage, 'Use ??= instead of explicit null check and assignment.');
    });

    test('reports a replaceable null check followed by assignment', () {
      final diagnostics = runAnalysisRule(
        PreferNullAwareAssignmentRule(),
        '''
void f(int? a) {
  if (a == null) {
    a = 42;
  }
}
''',
      );

      expect(diagnostics, hasLength(1));
    });

    test('does not report a null check that contains an else branch', () {
      final diagnostics = runAnalysisRule(
        PreferNullAwareAssignmentRule(),
        '''
void f(int? a) {
  if (a == null) {
    a = 42;
  } else {
    a = 10;
  }
}
''',
      );

      expect(diagnostics, isEmpty);
    });

    test('does not report a null check that assigns a different variable', () {
      final diagnostics = runAnalysisRule(
        PreferNullAwareAssignmentRule(),
        '''
void f(int? a, int? b) {
  if (a == null) {
    b = 42;
  }
}
''',
      );

      expect(diagnostics, isEmpty);
    });
  });
}
