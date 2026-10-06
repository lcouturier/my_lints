import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/style/avoid_redundant_duration_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidRedundantDurationRule', () {
    test('reports a zero-valued duration component', () async {
      final unit = await resolveSource('final delay = Duration(milliseconds: 0);');
      expect(runAnalysisRuleOnUnit(AvoidRedundantDurationRule(), unit), hasLength(1));
    });

    test('does not report a non-zero duration component', () async {
      final unit = await resolveSource('final delay = Duration(milliseconds: 10);');
      expect(runAnalysisRuleOnUnit(AvoidRedundantDurationRule(), unit), isEmpty);
    });
  });
}
