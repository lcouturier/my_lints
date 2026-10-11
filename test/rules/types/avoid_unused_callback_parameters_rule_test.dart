import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/types/avoid_unused_callback_parameters_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidUnusedCallbackParametersRule', () {
    test('reports unused parameter in forEach callback', () async {
      final unit = await resolveSource("void f(List<int> list) { list.forEach((item) { print('processing'); }); }");
      expect(runAnalysisRuleOnUnit(AvoidUnusedCallbackParametersRule(), unit), hasLength(1));
    });

    test('does not report used parameter in forEach callback', () async {
      final unit = await resolveSource("void f(List<int> list) { list.forEach((item) { print(item); }); }");
      expect(runAnalysisRuleOnUnit(AvoidUnusedCallbackParametersRule(), unit), isEmpty);
    });

    test('reports multiple unused parameters', () async {
      final unit = await resolveSource("void f() { someFunction((a, b) { print('test'); }); }");
      expect(runAnalysisRuleOnUnit(AvoidUnusedCallbackParametersRule(), unit), hasLength(2));
    });

    test('does not report underscore-prefixed parameters', () async {
      final unit = await resolveSource("void f(List<int> list) { list.forEach((_) { print('processing'); }); }");
      expect(runAnalysisRuleOnUnit(AvoidUnusedCallbackParametersRule(), unit), isEmpty);
    });

    test('does not report when parameter is used in nested expression', () async {
      final unit = await resolveSource("void f(List<int> list) { list.forEach((item) { print(item.toString()); }); }");
      expect(runAnalysisRuleOnUnit(AvoidUnusedCallbackParametersRule(), unit), isEmpty);
    });

    test('does not report in regular function (not callback)', () async {
      final unit = await resolveSource("void f(int a) { print('test'); }");
      expect(runAnalysisRuleOnUnit(AvoidUnusedCallbackParametersRule(), unit), isEmpty);
    });

    test('does not report empty parameter list', () async {
      final unit = await resolveSource("void f() { someFunction(() { print('test'); }); }");
      expect(runAnalysisRuleOnUnit(AvoidUnusedCallbackParametersRule(), unit), isEmpty);
    });

    test('reports when only some parameters are unused', () async {
      final unit = await resolveSource("void f() { someFunction((a, b) { print(a); }); }");
      expect(runAnalysisRuleOnUnit(AvoidUnusedCallbackParametersRule(), unit), hasLength(1));
    });

    test('reports when only some parameters are unused', () async {
      final unit = await resolveSource("void f() { someFunction((a, b) { print(a); }); }");
      expect(runAnalysisRuleOnUnit(AvoidUnusedCallbackParametersRule(), unit), hasLength(1));
    });
  });
}
