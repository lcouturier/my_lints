import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/flutter/avoid_disposable_state_field_leaks_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidDisposableStateFieldLeaksRule', () {
    test('reports a controller that is not disposed', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});
  @override
  State<ExampleWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleWidget> {
  final TextEditingController controller = TextEditingController();
  @override
  void dispose() { super.dispose(); }
  @override
  Widget build(BuildContext context) => const SizedBox();
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidDisposableStateFieldLeaksRule(), unit), hasLength(1));
    });

    test('does not report a disposed controller', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});
  @override
  State<ExampleWidget> createState() => ExampleState();
}

class ExampleState extends State<ExampleWidget> {
  final TextEditingController controller = TextEditingController();
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => const SizedBox();
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidDisposableStateFieldLeaksRule(), unit), isEmpty);
    });
  });
}
