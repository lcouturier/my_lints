import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/types/prefer_explicit_function_type_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferExplicitFunctionType', () {
    test('reports the bare Function type', () async {
      final unit = await resolveSource('Function callback;');
      expect(runAnalysisRuleOnUnit(PreferExplicitFunctionType(), unit), hasLength(1));
    });

    test('does not report an explicit function signature', () async {
      final unit = await resolveSource('void Function() callback;');
      expect(runAnalysisRuleOnUnit(PreferExplicitFunctionType(), unit), isEmpty);
    });
  });
}
