import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/flutter/prefer_keyed_widgets_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferKeyedWidgetsRule', () {
    test('reports widgets in a children list without keys', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';

class ExampleWidget extends StatelessWidget {
  const ExampleWidget({super.key});
  @override
  Widget build(BuildContext context) => Column(children: [Text('one'), Text('two')]);
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(PreferKeyedWidgetsRule(), unit), hasLength(2));
    });

    test('does not report a widget with a key', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';

class ExampleWidget extends StatelessWidget {
  const ExampleWidget({super.key});
  @override
  Widget build(BuildContext context) {
    const widgetKey = ValueKey('one');
    return Column(children: [Text('one', key: widgetKey)]);
  }
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(PreferKeyedWidgetsRule(), unit), isEmpty);
    });
  });
}
