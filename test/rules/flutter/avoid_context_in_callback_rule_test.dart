import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/flutter/avoid_context_in_callback_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidContextInCallbackRule', () {
    test('reports context used inside a callback', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => Scaffold.of(context).showBottomSheet(null),
      icon: const Icon(Icons.add),
    );
  }
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidContextInCallbackRule(), unit), hasLength(1));
    });

    test('does not report when context is not used in callback', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => print('no context'),
      icon: const Icon(Icons.add),
    );
  }
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidContextInCallbackRule(), unit), isEmpty);
    });

    test('does not report non-callback method invocations', () async {
      final unit = await resolveSource('''
import 'package:flutter/widgets.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: IconButton(
        onPressed: () => print('ok'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
''', useExamplePackages: true);

      expect(runAnalysisRuleOnUnit(AvoidContextInCallbackRule(), unit), isEmpty);
    });
  });
}