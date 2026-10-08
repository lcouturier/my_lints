import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/async/avoid_useless_async_method_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidUselessAsyncMethodRule', () {
    test('reports an async function without await', () {
      expect(runAnalysisRule(AvoidUselessAsyncMethodRule(), 'Future<void> save() async {}'), hasLength(1));
    });

    test('does not report an async function with await', () {
      expect(
        runAnalysisRule(AvoidUselessAsyncMethodRule(), 'Future<void> save() async { await Future<void>.value(); }'),
        isEmpty,
      );
    });

    test('does not report an async expression body', () async {
      final unit = await resolveSource('''
Future<void> save() async => await Future<void>.value();
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidUselessAsyncMethodRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report an async expression body', () async {
      final unit = await resolveSource('''
Future<void> save() async => Future<void>.value();
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidUselessAsyncMethodRule(), unit);

      expect(diagnostics, hasLength(1));
    });
  });
}
