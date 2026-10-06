import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/types/avoid_dynamic_type_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidDynamicTypeRule', () {
    test('reports explicit dynamic types', () async {
      final unit = await resolveSource('dynamic value(dynamic input) => input;');
      expect(runAnalysisRuleOnUnit(AvoidDynamicTypeRule(), unit), hasLength(2));
    });

    test('does not report explicit object types', () async {
      final unit = await resolveSource('Object value(Object input) => input;');
      expect(runAnalysisRuleOnUnit(AvoidDynamicTypeRule(), unit), isEmpty);
    });
  });
}
