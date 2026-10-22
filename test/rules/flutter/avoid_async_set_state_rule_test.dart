import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/flutter/avoid_async_set_state_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidAsyncSetStateRule', () {
    test('exposes the expected diagnostic', () {
      final diagnosticCode = AvoidAsyncSetStateRule().diagnosticCode;

      expect(diagnosticCode.name, 'avoid_async_set_state');
      expect(diagnosticCode.problemMessage, 'Do not pass an async callback to setState.');
      expect(
        diagnosticCode.correctionMessage,
        'Complete asynchronous work before calling setState and keep its callback synchronous.',
      );
    });

    test('reports an async callback passed to setState in a State class', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  String value = '';

  Future<void> save() async {}

  void update() {
    setState(() async {
      await save();
      value = 'saved';
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidAsyncSetStateRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does not report a synchronous setState callback', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  int value = 0;

  void update() {
    setState(() {
      value++;
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidAsyncSetStateRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report an async callback passed to another method', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  void register(void Function() callback) {}

  void update() {
    register(() async {});
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidAsyncSetStateRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report setState on a non-Flutter State class', () {
      final diagnostics = runAnalysisRule(AvoidAsyncSetStateRule(), '''
class NotFlutterState {
  void setState(Function callback) {}

  void update() {
    setState(() async {});
  }
}
''');

      expect(diagnostics, isEmpty);
    });
  });
}
