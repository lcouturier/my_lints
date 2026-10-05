import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/avoid_unawaited_futures_in_callbacks_rule.dart';

import '../rule_test_harness.dart';

void main() {
  group('AvoidUnawaitedFuturesInCallbacksRule', () {
    test('reports an unawaited future expression in a callback', () async {
      final unit = await resolveSource('''
Future<void> save() async {}
void register(void Function() callback) {}

void main() {
  register(() {
    save();
  });
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidUnawaitedFuturesInCallbacksRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does not report an awaited future in a callback', () async {
      final unit = await resolveSource('''
Future<void> save() async {}
void register(void Function() callback) {}

void main() {
  register(() async {
    await save();
  });
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidUnawaitedFuturesInCallbacksRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report an explicitly unawaited future in a callback', () async {
      final unit = await resolveSource('''
import 'dart:async';

Future<void> save() async {}
void register(void Function() callback) {}

void main() {
  register(() {
    unawaited(save());
  });
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidUnawaitedFuturesInCallbacksRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report an unawaited future outside a callback', () async {
      final unit = await resolveSource('''
Future<void> save() async {}

void main() {
  save();
}
''');

      final diagnostics = runAnalysisRuleOnUnit(AvoidUnawaitedFuturesInCallbacksRule(), unit);

      expect(diagnostics, isEmpty);
    });
  });
}
