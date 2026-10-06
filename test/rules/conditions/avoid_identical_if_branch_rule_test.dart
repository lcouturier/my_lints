import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/conditions/avoid_identical_if_branch_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidIdenticalIfBranchRule', () {
    test('reports identical branches', () {
      expect(
        runAnalysisRule(AvoidIdenticalIfBranchRule(), 'void f(bool value) { if (value) print(1); else print(1); }'),
        hasLength(1),
      );
    });

    test('does not report different branches', () {
      expect(
        runAnalysisRule(AvoidIdenticalIfBranchRule(), 'void f(bool value) { if (value) print(1); else print(2); }'),
        isEmpty,
      );
    });
  });
}
