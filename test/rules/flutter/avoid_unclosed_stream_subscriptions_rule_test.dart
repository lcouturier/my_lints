import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/flutter/avoid_unclosed_stream_subscriptions_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidUnclosedStreamSubscriptionsRule', () {
    test('reports a subscription that is not cancelled in dispose', () async {
      final unit = await resolveSource('''
import 'dart:async';
import 'package:flutter/widgets.dart';

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});
  @override
  State<ExampleWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleWidget> {
  late final StreamSubscription<int> _subscription;
  @override
  void dispose() { super.dispose(); }
  @override
  Widget build(BuildContext context) => const SizedBox();
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidUnclosedStreamSubscriptionsRule(), unit), hasLength(1));
    });

    test('does not report a subscription cancelled in dispose', () async {
      final unit = await resolveSource('''
import 'dart:async';
import 'package:flutter/widgets.dart';

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});
  @override
  State<ExampleWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleWidget> {
  late final StreamSubscription<int> _subscription;
  @override
  void dispose() { _subscription.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) => const SizedBox();
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidUnclosedStreamSubscriptionsRule(), unit), isEmpty);
    });

    test('reports a subscription only scheduled for cancellation in dispose', () async {
      final unit = await resolveSource('''
import 'dart:async';
import 'package:flutter/widgets.dart';

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});
  @override
  State<ExampleWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleWidget> {
  late final StreamSubscription<int> _subscription;
  @override
  void dispose() {
    scheduleMicrotask(() { _subscription.cancel(); });
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => const SizedBox();
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidUnclosedStreamSubscriptionsRule(), unit), hasLength(1));
    });

    test('reports a subscription when dispose is missing', () async {
      final unit = await resolveSource('''
import 'dart:async';
import 'package:flutter/widgets.dart';

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});
  @override
  State<ExampleWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleWidget> {
  late final StreamSubscription<int> _subscription;
  @override
  Widget build(BuildContext context) => const SizedBox();
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidUnclosedStreamSubscriptionsRule(), unit), hasLength(1));
    });

    test('does not report a stream subscription outside a State class', () async {
      final unit = await resolveSource('''
import 'dart:async';

class Example {
  late final StreamSubscription<int> subscription;
}
''');

      expect(runAnalysisRuleOnUnit(AvoidUnclosedStreamSubscriptionsRule(), unit), isEmpty);
    });
  });
}
