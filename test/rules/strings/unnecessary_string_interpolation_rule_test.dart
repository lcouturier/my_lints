import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/strings/unnecessary_string_interpolation_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('UnnecessaryStringInterpolationRule', () {
    test('reports braces around an identifier at the end of a string', () {
      expect(
        runAnalysisRule(UnnecessaryStringInterpolationRule(), 'String format(String name) => "\${name}";'),
        hasLength(1),
      );
    });

    test('does not report braces needed before a following identifier character', () {
      expect(
        runAnalysisRule(UnnecessaryStringInterpolationRule(), 'String format(String name) => "\${name}Suffix";'),
        isEmpty,
      );
    });
  });
}
