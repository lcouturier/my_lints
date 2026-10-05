import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/collections/prefer_any_or_every_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferAnyRule', () {
    test('exposes the expected diagnostic code', () {
      expect(PreferAnyRule().diagnosticCode.name, 'prefer_any');
    });

    test('reports where results checked for emptiness on iterables', () async {
      final unit = await resolveSource('''
void f(List<int> values, Map<String, int> counts) {
  values.where((value) => value.isEven).isNotEmpty;
  values.where((value) => value < 0).isEmpty;
  counts.values.where((value) => value > 0).isNotEmpty;
}
''');

      final diagnostics = runAnalysisRuleOnUnit(PreferAnyRule(), unit);

      expect(diagnostics.map((node) => node.toSource()), [
        'values.where((value) => value.isEven).isNotEmpty',
        'values.where((value) => value < 0).isEmpty',
        'counts.values.where((value) => value > 0).isNotEmpty',
      ]);
    });

    test('ignores other properties and non-iterable where results', () async {
      final unit = await resolveSource('''
class SearchResult {
  bool get isEmpty => false;
}

class Search {
  SearchResult where(bool Function(int) predicate) => SearchResult();
}

void f(List<int> values, Search search) {
  values.where((value) => value.isEven).length;
  values.take(1).isEmpty;
  search.where((value) => value.isEven).isEmpty;
}
''');

      final diagnostics = runAnalysisRuleOnUnit(PreferAnyRule(), unit);

      expect(diagnostics, isEmpty);
    });
  });
}
