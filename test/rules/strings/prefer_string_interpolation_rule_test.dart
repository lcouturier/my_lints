import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/strings/prefer_string_interpolation_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferStringInterpolationRule', () {
    test('reports string concatenation with an identifier', () async {
      final unit = await resolveSource("String greet(String name) => 'Hello, ' + name;");
      expect(runAnalysisRuleOnUnit(PreferStringInterpolationRule(), unit), hasLength(1));
    });

    test('reports string concatenation with an identifier in reverse order', () async {
      final unit = await resolveSource("String greet(String name) => name + 'Hello, ';");
      expect(runAnalysisRuleOnUnit(PreferStringInterpolationRule(), unit), hasLength(1));
    });

    test('does not report string interpolation with an identifier', () async {
      final unit = await resolveSource("String greet(String name) => 'Hello, \$name';");
      expect(runAnalysisRuleOnUnit(PreferStringInterpolationRule(), unit), isEmpty);
    });

    test('does not report numeric addition', () async {
      final unit = await resolveSource('int sum() => 1 + 2;');
      expect(runAnalysisRuleOnUnit(PreferStringInterpolationRule(), unit), isEmpty);
    });

    test('does not report string concatenation with string literals', skip: true, () async {
      final unit = await resolveSource("String greet() => 'Hello, ' + 'World';");
      expect(runAnalysisRuleOnUnit(PreferStringInterpolationRule(), unit), isEmpty);
    });
  });
}
