import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/types/prefer_function_typedefs_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferFunctionTypedefsRule', () {
    test('reports an inline function parameter type', () async {
      final unit = await resolveSource('void execute(void Function() callback) {}');
      expect(runAnalysisRuleOnUnit(PreferFunctionTypedefsRule(), unit), hasLength(1));
    });

    test('does not report a typedef callback parameter', () async {
      final unit = await resolveSource('typedef Callback = void Function();\nvoid execute(Callback callback) {}');
      expect(runAnalysisRuleOnUnit(PreferFunctionTypedefsRule(), unit), isEmpty);
    });
  });
}
