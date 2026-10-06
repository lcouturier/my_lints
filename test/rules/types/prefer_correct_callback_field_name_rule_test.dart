import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/types/prefer_correct_callback_field_name_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferCorrectCallbackFieldNameRule', () {
    test('reports a callback field without the on prefix', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';
class ExampleWidget extends StatelessWidget {
  final VoidCallback callback;
  const ExampleWidget(this.callback);
  @override
  Widget build(BuildContext context) => const SizedBox();
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(PreferCorrectCallbackFieldNameRule(), unit), hasLength(1));
    });

    test('does not report a callback field with the on prefix', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';
class ExampleWidget extends StatelessWidget {
  final VoidCallback onPressed;
  const ExampleWidget(this.onPressed);
  @override
  Widget build(BuildContext context) => const SizedBox();
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(PreferCorrectCallbackFieldNameRule(), unit), isEmpty);
    });
  });
}
