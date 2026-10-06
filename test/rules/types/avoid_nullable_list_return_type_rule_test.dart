import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/types/avoid_nullable_list_return_type_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidNullableListReturnTypeRule', () {
    test('reports a nullable list parameter', () async {
      final unit = await resolveSource('void update(List<int>? values) {}');
      expect(runAnalysisRuleOnUnit(AvoidNullableListReturnTypeRule(), unit), hasLength(1));
    });

    test('does not report a non-nullable list parameter', () async {
      final unit = await resolveSource('void update(List<int> values) {}');
      expect(runAnalysisRuleOnUnit(AvoidNullableListReturnTypeRule(), unit), isEmpty);
    });
  });
}
