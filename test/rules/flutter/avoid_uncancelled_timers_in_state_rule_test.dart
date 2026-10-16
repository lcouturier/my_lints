import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/flutter/avoid_uncancelled_timers_in_state_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidUncancelledTimersInStateRule', () {
    test('exposes the expected diagnostic metadata', () {
      final rule = AvoidUncancelledTimersInStateRule();

      expect(rule.diagnosticCode.name, 'avoid_uncancelled_timers_in_state');
      expect(rule.diagnosticCode.problemMessage, 'Timer "{0}" is not cancelled in dispose().');
      expect(rule.diagnosticCode.correctionMessage, 'Call cancel() on the timer in dispose().');
      expect(registeredNodeTypes(rule), {'ClassDeclaration'});
    });

    test('reports a Timer field when dispose is missing', () async {
      final unit = await resolveSource('''
import 'dart:async';
import 'package:flutter/widgets.dart';

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});
  @override
  State<ExampleWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleWidget> {
  Timer? timer;
  @override
  Widget build(BuildContext context) => const SizedBox();
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidUncancelledTimersInStateRule(), unit), hasLength(1));
    });

    test('reports a Timer field not cancelled in dispose', () async {
      final unit = await resolveSource('''
import 'dart:async';
import 'package:flutter/widgets.dart';

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});
  @override
  State<ExampleWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleWidget> {
  Timer? timer;
  @override
  void dispose() { super.dispose(); }
  @override
  Widget build(BuildContext context) => const SizedBox();
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidUncancelledTimersInStateRule(), unit), hasLength(1));
    });

    test('does not report a nullable Timer cancelled in dispose', () async {
      final unit = await resolveSource('''
import 'dart:async';
import 'package:flutter/widgets.dart';

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});
  @override
  State<ExampleWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleWidget> {
  Timer? timer;
  @override
  void dispose() { timer?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) => const SizedBox();
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidUncancelledTimersInStateRule(), unit), isEmpty);
    });

    test('does not report cancellation through nested local helpers', () async {
      final unit = await resolveSource('''
import 'dart:async';
import 'package:flutter/widgets.dart';

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});
  @override
  State<ExampleWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleWidget> {
  Timer? timer;
  void cancelTimer() { timer?.cancel(); }
  @override
  void dispose() { cancelTimer(); super.dispose(); }
  @override
  Widget build(BuildContext context) => const SizedBox();
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidUncancelledTimersInStateRule(), unit), isEmpty);
    });

    test('reports cancellation deferred in a closure', () async {
      final unit = await resolveSource('''
import 'dart:async';
import 'package:flutter/widgets.dart';

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});
  @override
  State<ExampleWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleWidget> {
  Timer? timer;
  @override
  void dispose() {
    scheduleMicrotask(() { timer?.cancel(); });
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => const SizedBox();
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidUncancelledTimersInStateRule(), unit), hasLength(1));
    });

    test('does not report static Timer fields', () async {
      final unit = await resolveSource('''
import 'dart:async';
import 'package:flutter/widgets.dart';

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});
  @override
  State<ExampleWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleWidget> {
  static Timer? timer;
  @override
  Widget build(BuildContext context) => const SizedBox();
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidUncancelledTimersInStateRule(), unit), isEmpty);
    });

    test('does not report Timer fields outside a State class', () async {
      final unit = await resolveSource('''
import 'dart:async';

class Example {
  Timer? timer;
}
''');

      expect(runAnalysisRuleOnUnit(AvoidUncancelledTimersInStateRule(), unit), isEmpty);
    });

    test('does not report an unrelated type named Timer', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';

class Timer {}

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});
  @override
  State<ExampleWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleWidget> {
  Timer? timer;
  @override
  Widget build(BuildContext context) => const SizedBox();
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidUncancelledTimersInStateRule(), unit), isEmpty);
    });
  });
}
