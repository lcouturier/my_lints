import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/collections/prefer_spread_for_addall_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferSpreadForAddallRule metadata', () {
    test('exposes expected diagnostic code', () {
      final rule = PreferSpreadForAddallRule();

      expect(rule.diagnosticCode.name, 'prefer_spread_for_addAll');
      expect(rule.diagnosticCode.problemMessage, 'Use spread operator (...) instead of addAll().');
      expect(rule.diagnosticCode.correctionMessage, 'Replace addAll() with spread operator.');
    });
  });

  test('reports addAll on List', () async {
    final unit = await resolveSource('''
void bar() {
  final list = <int>[1, 2];
  list.addAll([3, 4]);
}
''');

    final diagnostics = runAnalysisRuleOnUnit(PreferSpreadForAddallRule(), unit);

    expect(diagnostics, hasLength(1));
  });

  test('reports addAll on Set', () async {
    final unit = await resolveSource('''
void bar() {
  final set = <int>{1, 2};
  set.addAll({3, 4});
}
''');

    final diagnostics = runAnalysisRuleOnUnit(PreferSpreadForAddallRule(), unit);

    expect(diagnostics, hasLength(1));
  });

  test('reports addAll on Map', () async {
    final unit = await resolveSource('''
void bar() {
  final map = <String, int>{'a': 1};
  map.addAll({'b': 2});
}
''');

    final diagnostics = runAnalysisRuleOnUnit(PreferSpreadForAddallRule(), unit);

    expect(diagnostics, hasLength(1));
  });

  test('does not report when method is not addAll', () async {
    final unit = await resolveSource('''
void bar() {
  final list = <int>[1, 2];
  list.add(3);
}
''');

    final diagnostics = runAnalysisRuleOnUnit(PreferSpreadForAddallRule(), unit);

    expect(diagnostics, isEmpty);
  });

  test('does not report when target is not a collection', () async {
    final unit = await resolveSource('''
void bar() {
  final custom = CustomObject();
  custom.addAll([1, 2]);
}

class CustomObject {
  void addAll(List<int> items) {}
}
''');

    final diagnostics = runAnalysisRuleOnUnit(PreferSpreadForAddallRule(), unit);

    expect(diagnostics, isEmpty);
  });

  test('does not report when addAll has multiple arguments', () async {
    final unit = await resolveSource('''
void bar() {
  final list = <int>[1, 2];
  list.addAll([3, 4], [5, 6]);
}
''');

    final diagnostics = runAnalysisRuleOnUnit(PreferSpreadForAddallRule(), unit);

    expect(diagnostics, isEmpty);
  });
}
