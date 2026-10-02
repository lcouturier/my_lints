import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/prefer_first_rule.dart';

import '../rule_test_harness.dart';

void main() {
  group('PreferFirstRule metadata', () {
    test('exposes expected diagnostic code', () {
      final rule = PreferFirstRule();

      expect(rule.diagnosticCode.name, 'prefer_first_over_index');
      expect(rule.diagnosticCode.problemMessage, "Use '.first' instead of accessing the first element by index.");
      expect(rule.diagnosticCode.correctionMessage, "Replace with '.first'.");
    });
  });

  group('isFirstElementAccess in index expression', () {
    test('reports where results checked for emptiness on iterables', () async {
      final unit = await resolveSource('''
void bar() {
  final List<int> list = [1, 2, 3];
  final first = list[0];
  final second = list[1];
}
''');

      final diagnostics = runAnalysisRuleOnUnit(PreferFirstRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does not report for non-first element access', () async {
      final unit = await resolveSource('''
void bar() {
  final List<int> list = [1, 2, 3];
  final second = list[1];
}
''');

      final diagnostics = runAnalysisRuleOnUnit(PreferFirstRule(), unit);

      expect(diagnostics, isEmpty);
    });
  });

  group('isFirstElementAccess in method invocation', () {
    test('reports for first element accessed via elementAt', () async {
      final unit = await resolveSource('''
void bar() {
  final List<int> list = [1, 2, 3];
  final first = list.elementAt(0);
}
''');
      final diagnostics = runAnalysisRuleOnUnit(PreferFirstRule(), unit);
      expect(diagnostics, hasLength(1));
    });

    test('does not report for non-first element access', () async {
      final unit = await resolveSource('''
void bar() {
  final List<int> list = [1, 2, 3];
  final second = list.elementAt(1);
}
''');

      final diagnostics = runAnalysisRuleOnUnit(PreferFirstRule(), unit);

      expect(diagnostics, isEmpty);
    });
  });
}
