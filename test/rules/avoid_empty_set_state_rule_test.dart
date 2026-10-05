import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/avoid_empty_set_state_rule.dart';

import '../rule_test_harness.dart';

void main() {
  group('AvoidEmptySetStateRule', () {
    test('reports an empty setState callback', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {});
      },
      child: Text('Press me'),
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidEmptySetStateRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does not report a non-empty setState callback', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          Future.delayed(Duration(seconds: 1));
        });
      },
      child: Text('Press me'),
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidEmptySetStateRule(), unit);

      expect(diagnostics, isEmpty);
    });
  });
}
