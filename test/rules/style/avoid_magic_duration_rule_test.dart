import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/style/avoid_magic_duration_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidMagicDurationRule', () {
    test('reports non-zero literal duration components', () async {
      final unit = await resolveSource('final delay = Duration(seconds: 5);');
      expect(runAnalysisRuleOnUnit(AvoidMagicDurationRule(), unit), hasLength(1));
    });

    test('does not report zero duration components', () async {
      final unit = await resolveSource('final delay = Duration(seconds: 0);');
      expect(runAnalysisRuleOnUnit(AvoidMagicDurationRule(), unit), isEmpty);
    });
  });
}
