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
  });
}
