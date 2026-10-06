import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/types/prefer_named_bool_parameters_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferNamedBooleanParametersRule', () {
    test('reports a positional boolean parameter', () async {
      final unit = await resolveSource('void save(bool force) {}');
      expect(runAnalysisRuleOnUnit(PreferNamedBooleanParametersRule(), unit), hasLength(1));
    });

    test('does not report a named boolean parameter', () async {
      final unit = await resolveSource('void save({required bool force}) {}');
      expect(runAnalysisRuleOnUnit(PreferNamedBooleanParametersRule(), unit), isEmpty);
    });
  });
}
