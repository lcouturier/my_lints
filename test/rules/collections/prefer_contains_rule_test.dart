import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/collections/prefer_contains_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferContainsRule metadata', () {
    test('exposes expected diagnostic code', () {
      final rule = PreferContainsRule();

      expect(rule.diagnosticCode.name, 'prefer_contains_over_indexOf');
      expect(rule.diagnosticCode.problemMessage, 'Use .contains() instead of .indexOf() compared to -1.');
      expect(rule.diagnosticCode.correctionMessage, 'Replace with .contains() for better readability.');
    });
  });

  group('isIndexOfComparedToMinusOne', () {
    test('reports where results checked for emptiness on iterables', () async {
      final unit = await resolveSource('''
void bar(List<int> values, int value) {
  final isMissing = values.indexOf(value) == -1;
}
''');

      final diagnostics = runAnalysisRuleOnUnit(PreferContainsRule(), unit);

      expect(diagnostics, hasLength(1));
    });
  });

  test('does not report when indexOf is not compared to -1', () async {
    final unit = await resolveSource('''
void bar(List<int> values, int value) {
  final isAtFirstPosition = values.indexOf(value) == 0;
}
''');

    final diagnostics = runAnalysisRuleOnUnit(PreferContainsRule(), unit);

    expect(diagnostics, isEmpty);
  });

  test('does not report when indexOf is not used', () async {
    final unit = await resolveSource('''
void bar(List<int> values, int value) {
  final isEmpty = values.isEmpty;
}
''');

    final diagnostics = runAnalysisRuleOnUnit(PreferContainsRule(), unit);

    expect(diagnostics, isEmpty);
  });

  test('reports when indexOf is compared to -1 using !=', () async {
    final unit = await resolveSource('''
void bar(List<int> values, int value) {
  final isPresent = values.indexOf(value) != -1;
}
''');

    final diagnostics = runAnalysisRuleOnUnit(PreferContainsRule(), unit);

    expect(diagnostics, hasLength(1));
  });
}
