import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/conditions/avoid_conditional_expression_in_parameter_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidConditionalExpressionInParameterRule', () {
    test('reports a conditional used as an argument value', () {
      final diagnostics = runAnalysisRule(AvoidConditionalExpressionInParameterRule(), '''
void accept(bool value) {}
void call(bool condition) => accept(condition ? true : false);
''');

      expect(diagnostics, hasLength(1));
    });

    test('does not report a conditional outside an argument list', () {
      final diagnostics = runAnalysisRule(AvoidConditionalExpressionInParameterRule(), '''
int choose(bool condition) => condition ? 1 : 0;
''');

      expect(diagnostics, isEmpty);
    });
  });
}
