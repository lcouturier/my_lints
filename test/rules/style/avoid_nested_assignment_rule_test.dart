import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/style/avoid_nested_assignment_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidNestedAssignmentRule', () {
    test('exposes the expected diagnostic code', () {
      final rule = AvoidNestedAssignmentRule();
      expect(rule.diagnosticCode.name, 'avoid_nested_assignment');
      expect(
        rule.diagnosticCode.problemMessage,
        'Nested assignments can lead to confusion or indicate an incorrect operator (= instead of ==).',
      );
    });
  });

  test('reports a nested assignment statement', () async {
    final unit = await resolveSource('''
void f(int a, int b) {
  a = b = 42;
}
''', useWorkspacePackages: true);

    final diagnostics = runAnalysisRuleOnUnit(AvoidNestedAssignmentRule(), unit);

    expect(diagnostics, hasLength(1));
  });

  test('reports a nested assignment statement with compound assignment', () async {
    final unit = await resolveSource('''
void f(int a, int b) {
  a += b = 42;
}
''', useWorkspacePackages: true);

    final diagnostics = runAnalysisRuleOnUnit(AvoidNestedAssignmentRule(), unit);

    expect(diagnostics, hasLength(1));
  });

  test('does not report a non-nested assignment statement', () async {
    final unit = await resolveSource('''
void f(int a, int b) {
  a = 42;
  b = 42;
}
''', useWorkspacePackages: true);

    final diagnostics = runAnalysisRuleOnUnit(AvoidNestedAssignmentRule(), unit);

    expect(diagnostics, isEmpty);
  });
}
