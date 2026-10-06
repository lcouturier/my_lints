import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/strings/avoid_nullable_interpolation_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidNullableInterpolationRule', () {
    test('reports nullable values in string interpolation', () async {
      final unit = await resolveSource('''
String format(String? value) => '\$value';
''');

      expect(runAnalysisRuleOnUnit(AvoidNullableInterpolationRule(), unit), hasLength(1));
    });

    test('does not report non-nullable interpolated values', () async {
      final unit = await resolveSource('''
String format(String value) => '\$value';
''');

      expect(runAnalysisRuleOnUnit(AvoidNullableInterpolationRule(), unit), isEmpty);
    });
  });
}
