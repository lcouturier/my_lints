import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/strings/prefer_string_interpolation_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferStringInterpolationRule', () {
    test('reports string concatenation with an identifier', () {
      expect(
        runAnalysisRule(PreferStringInterpolationRule(), "String greet(String name) => 'Hello, ' + name;"),
        hasLength(1),
      );
    });

    test('reports string concatenation with an identifier in reverse order', () {
      expect(
        runAnalysisRule(PreferStringInterpolationRule(), "String greet(String name) => name + 'Hello, ';"),
        hasLength(1),
      );
    });

    test('does not report string interpolation with an identifier', () {
      expect(
        runAnalysisRule(PreferStringInterpolationRule(), "String greet(String name) => 'Hello, \$name';"),
        isEmpty,
      );
    });

    test('does not report numeric addition', () {
      expect(runAnalysisRule(PreferStringInterpolationRule(), 'int sum() => 1 + 2;'), isEmpty);
    });
  });
}
