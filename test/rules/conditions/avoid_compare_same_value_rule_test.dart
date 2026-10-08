import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/conditions/avoid_compare_same_value_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidCompareSameValueRule', () {
    test('reports equality comparisons of the same identifier', () {
      expect(runAnalysisRule(AvoidCompareSameValueRule(), 'bool same(bool value) => value == value;'), hasLength(1));
    });

    test('does not report an assignment in a complex condition with ||', () async {
      final unit = await resolveSource('''
bool same(bool value) => value == value;
''');
      final diagnostics = runAnalysisRuleOnUnit(AvoidCompareSameValueRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('reports inequality comparisons of the same identifier', () async {
      final unit = await resolveSource('''
bool same(bool value) => value != value;
''');
      final diagnostics = runAnalysisRuleOnUnit(AvoidCompareSameValueRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does not report comparisons of different identifiers', () async {
      final unit = await resolveSource('''
bool same(bool left, bool right) => left == right;
''');
      final diagnostics = runAnalysisRuleOnUnit(AvoidCompareSameValueRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report comparisons of the same identifier in a complex expression', () async {
      final unit = await resolveSource('''
bool same(bool value) => value == value || value != value;
''');
      final diagnostics = runAnalysisRuleOnUnit(AvoidCompareSameValueRule(), unit);

      expect(diagnostics, hasLength(2));
    });
  });
}
