import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/conditions/avoid_assignation_in_condition_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidAssignationInConditionRule', () {
    test('exposes the expected diagnostic code', () {
      expect(AvoidAssignationInConditionRule().diagnosticCode.name, 'avoid_assignation_in_condition');
    });

    test('reports an assignment on the left side of a condition', () async {
      final unit = await resolveSource('''
void f() {
  var value = 0;
  if ((value = 1) == 1) {
    print(value);
  }
}
''');
      final diagnostics = runAnalysisRuleOnUnit(AvoidAssignationInConditionRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does not report a normal comparison or an assignment outside a condition', () async {
      final unit = await resolveSource('''
void f(int value) {
  final assigned = value;
  if (value == 1) {
    print(assigned);
  }
}
''');
      final diagnostics = runAnalysisRuleOnUnit(AvoidAssignationInConditionRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report an assignment on the right side of a condition', () async {
      final unit = await resolveSource('''
void f() {
  var value = 0;
  if (1 == (value = 1)) {
    print(value);
  }
}
''');
      final diagnostics = runAnalysisRuleOnUnit(AvoidAssignationInConditionRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does not report an assignment in a complex condition', () async {
      final unit = await resolveSource('''
void f() {
  var value = 0;
  if ((value = 1) == 1 && (value = 2) == 2) {
    print(value);
  }
}
''');
      final diagnostics = runAnalysisRuleOnUnit(AvoidAssignationInConditionRule(), unit);

      expect(diagnostics, hasLength(2));
    });

    test('does not report an assignment in a complex condition with ||', () async {
      final unit = await resolveSource('''
void f() {
  var value = 0;
  if ((value = 1) == 1 || (value = 2) == 2) {
    print(value);
  }
}
''');
      final diagnostics = runAnalysisRuleOnUnit(AvoidAssignationInConditionRule(), unit);

      expect(diagnostics, hasLength(2));
    });
  });
}
