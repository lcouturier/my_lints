import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/flutter/prefer_no_spacing_over_divide_widgets_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferSpacingOverDivideWidgetsRule', () {
    test('reports Column children using divideWidgets', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';

class ExampleWidget extends StatelessWidget {
  const ExampleWidget({super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: [const Text('one'), const Text('two')].divideWidgets(const SizedBox(height: 8)),
  );
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(PreferSpacingOverDivideWidgetsRule(), unit), hasLength(1));
    });

    test('does not report a Column with an ordinary children list', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';

class ExampleWidget extends StatelessWidget {
  const ExampleWidget({super.key});
  @override
  Widget build(BuildContext context) => Column(children: const [Text('one'), Text('two')]);
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(PreferSpacingOverDivideWidgetsRule(), unit), isEmpty);
    });
  });
}
