import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/flutter/avoid_context_in_init_state_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidContextInInitStateRule', () {
    test('reports BuildContext use in initState', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});
  @override
  State<ExampleWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleWidget> {
  @override
  void initState() {
    super.initState();
    Navigator.of(context);
  }
  @override
  Widget build(BuildContext context) => const SizedBox();
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidContextInInitStateRule(), unit), hasLength(1));
    });

    test('does not report BuildContext use in build', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});
  @override
  State<ExampleWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleWidget> {
  @override
  Widget build(BuildContext context) => Navigator.of(context).widget;
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidContextInInitStateRule(), unit), isEmpty);
    });
  });
}
