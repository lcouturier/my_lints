import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/collections/prefer_map_sum_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferMapSumRule', () {
    test('exposes and registers the diagnostic', () {
      expect(PreferMapSumRule.code.name, 'prefer_map_sum');
      expect(PreferMapSumRule.code.problemMessage, contains('map and sum'));
      expect(PreferMapSumRule.code.correctionMessage, contains('extension'));
      expect(registeredNodeTypes(PreferMapSumRule()), {'MethodInvocation'});
    });

    test('reports integer iterable folds, including null-aware chains', () async {
      final unit = await resolveSource('''
class Product {
  List<int> tickets = [];
}
class NetworkTickets {
  List<Product> availableProducts = [];
}
extension IntegerSum on Iterable<int> {
  int get sum => 0;
}
void f(NetworkTickets? networkTickets, List<String> values, Iterable<int> numbers) {
  networkTickets?.availableProducts.fold<int>(
    0, (sum, t) => sum + t.tickets.length,
  );
  values.fold(0, (total, value) => total + value.length);
  numbers.fold<int>((0), (total, number) => (total) + (number * 2));
  networkTickets?.availableProducts.map((t) => t.tickets.length).sum;
}
''');

      final diagnostics = runAnalysisRuleOnUnit(PreferMapSumRule(), unit);
      expect(diagnostics.map((node) => node.toSource()), ['fold', 'fold', 'fold']);
    });

    test('ignores folds that cannot safely become an integer map and sum', () async {
      final unit = await resolveSource('''
class Custom {
  int fold(int initial, int Function(int, int) callback) => 0;
}
void f(List<int> values, List<double> doubles, Custom custom) {
  values.fold<int>(1, (sum, value) => sum + value);
  values.fold<int>(0, (sum, value) => sum - value);
  values.fold<int>(0, (sum, value) => sum + sum * value);
  values.fold<int>(0, (sum, value) => value + sum);
  values.fold<int>(0, (sum, value) { return sum + value; });
  values.fold<num>(0, (sum, value) => sum + value);
  doubles.fold<double>(0.0, (sum, value) => sum + value);
  custom.fold(0, (sum, value) => sum + value);
}
''');

      expect(runAnalysisRuleOnUnit(PreferMapSumRule(), unit), isEmpty);
    });

    test('ignores references to the accumulator inside nested expressions', () async {
      final unit = await resolveSource('''
void f(List<int> values) {
  values.fold<int>(0, (sum, value) => sum + (() => sum + value)());
  values.fold<int>(0, (sum, value) => sum + (sum = value));
}
''');

      expect(runAnalysisRuleOnUnit(PreferMapSumRule(), unit), isEmpty);
    });
  });
}
