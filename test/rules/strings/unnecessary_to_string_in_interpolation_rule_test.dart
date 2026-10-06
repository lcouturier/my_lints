import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/strings/unnecessary_to_string_in_interpolation_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('UnnecessaryToStringInInterpolationRule', () {
    test('reports toString inside interpolation', () {
      expect(
        runAnalysisRule(
          UnnecessaryToStringInInterpolationRule(),
          'String format(Object value) => "\${value.toString()}";',
        ),
        hasLength(1),
      );
    });

    test('does not report a direct interpolation', () {
      expect(
        runAnalysisRule(UnnecessaryToStringInInterpolationRule(), 'String format(Object value) => "\$value";'),
        isEmpty,
      );
    });
  });
}
