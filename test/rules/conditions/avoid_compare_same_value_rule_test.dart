import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/conditions/avoid_compare_same_value_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidCompareSameValueRule', () {
    test('reports equality comparisons of the same identifier', () {
      expect(runAnalysisRule(AvoidCompareSameValueRule(), 'bool same(bool value) => value == value;'), hasLength(1));
    });

    test('does not report comparisons of different identifiers', () {
      expect(
        runAnalysisRule(AvoidCompareSameValueRule(), 'bool same(bool left, bool right) => left == right;'),
        isEmpty,
      );
    });
  });
}
