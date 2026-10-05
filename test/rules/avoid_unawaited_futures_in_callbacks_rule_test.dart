import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/avoid_unawaited_futures_in_callbacks_rule.dart';

import '../rule_test_harness.dart';

void main() {
  group('AvoidUnawaitedFuturesInCallbacksRule', () {
    test('reports an unawaited future expression in a callback', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Future.delayed(Duration(seconds: 1));
      },
      child: Text('Press me'),
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidUnawaitedFuturesInCallbacksRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('reports an unawaited future expression in a callback', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await Future.delayed(Duration(seconds: 1));
      },
      child: Text('Press me'),
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidUnawaitedFuturesInCallbacksRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('reports multiple unawaited futures in a callback', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Future.delayed(Duration(seconds: 1));
        Future.delayed(Duration(seconds: 2));
      },
      child: Text('Press me'),
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidUnawaitedFuturesInCallbacksRule(), unit);

      expect(diagnostics, hasLength(2));
    });

    test('does not report an awaited future in a callback', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

Future<void> save() async {}

void main() {
  ElevatedButton(onPressed: () async { await save(); }, child: const Text('Save'));
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidUnawaitedFuturesInCallbacksRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report an explicitly unawaited future in a callback', () async {
      final unit = await resolveSource('''
import 'dart:async';
import 'package:flutter/material.dart';

Future<void> save() async {}

void main() {
  ElevatedButton(onPressed: () { unawaited(save()); }, child: const Text('Save'));
}
''', useWorkspacePackages: true);

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

    test('does not report an unawaited future in a non-widget callback', () async {
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

      expect(diagnostics, isEmpty);
    });
  });
}
