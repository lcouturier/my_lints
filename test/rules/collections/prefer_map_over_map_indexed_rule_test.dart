import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/collections/prefer_map_over_map_indexed_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferMapOverMapIndexedRule', () {
    test('reports mapIndexed when the index is unused', () async {
      final unit = await resolveSource('''
extension IndexedMap<T> on Iterable<T> {
  Iterable<R> mapIndexed<R>(R Function(int, T) convert) => [];
}

Iterable<int> convert(List<String> values) => values.mapIndexed((index, value) => value.length);
''');

      expect(runAnalysisRuleOnUnit(PreferMapOverMapIndexedRule(), unit), hasLength(1));
    });

    test('does not report mapIndexed when the index is used', () async {
      final unit = await resolveSource('''
extension IndexedMap<T> on Iterable<T> {
  Iterable<R> mapIndexed<R>(R Function(int, T) convert) => [];
}

Iterable<String> convert(List<String> values) => values.mapIndexed((index, value) => '\$index: \$value');
''');

      expect(runAnalysisRuleOnUnit(PreferMapOverMapIndexedRule(), unit), isEmpty);
    });
  });
}
