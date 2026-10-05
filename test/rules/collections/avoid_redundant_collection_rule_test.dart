import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/collections/avoid_redundant_collection_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidRedundantCollectionRule', () {
    test('exposes the expected diagnostic code', () {
      expect(AvoidRedundantCollectionRule().diagnosticCode.name, 'avoid_redundant_collection');
    });

    test('reports from and of constructors for supported collections', () async {
      final unit = await resolveSource('''
void f(
  Map<String, String> sourceMap,
  List<int> sourceList,
  Set<int> sourceSet,
) {
  Map<String, String>.from(sourceMap);
  Map<String, String>.of(sourceMap);
  List<int>.from(sourceList);
  List<int>.of(sourceList);
  Set<int>.from(sourceSet);
  Set<int>.of(sourceSet);
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidRedundantCollectionRule(), unit);

      expect(diagnostics, hasLength(6));
    });

    test('does not report iterable factories or collection literals', () async {
      final unit = await resolveSource('''
void f(List<int> values, Map<String, int> entries) {
  Map<String, int>.fromIterable(values);
  Map<String, int>.fromEntries(entries.entries);
  List<int>.from([1, 2]);
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidRedundantCollectionRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report non-collection constructors', () async {
      final unit = await resolveSource('''
class Person {
  Person.from(String value) {}
}

void f(String value) {
  Person.from(value);
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidRedundantCollectionRule(), unit);

      expect(diagnostics, isEmpty);
    });
  });
}
