import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/style/avoid_self_assignment_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidSelfAssignmentRule', () {
    test('reports assigning an identifier to itself', () {
      expect(runAnalysisRule(AvoidSelfAssignmentRule(), 'void f(int value) { value = value; }'), hasLength(1));
    });

    test('does not report assigning a different value', () {
      expect(runAnalysisRule(AvoidSelfAssignmentRule(), 'void f(int value) { value = 1; }'), isEmpty);
    });
  });
}
