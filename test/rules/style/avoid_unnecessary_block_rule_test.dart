import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/style/avoid_unnecessary_block_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidUnnecessaryBlockRule', () {
    test('reports a nested block statement', () {
      expect(runAnalysisRule(AvoidUnnecessaryBlockRule(), 'void f() { { print(1); } }'), hasLength(1));
    });

    test('does not report a normal function block', () {
      expect(runAnalysisRule(AvoidUnnecessaryBlockRule(), 'void f() { print(1); }'), isEmpty);
    });
  });
}
