import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/flutter/avoid_mounted_in_setstate.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidMountedInSetStateRule metadata', () {
    test('has correct name and description', () {
      final rule = AvoidMountedInSetStateRule();
      expect(rule.name, 'avoid_mounted_in_set_state');
      expect(rule.description, 'Never use mounted in a setState callback.');
    });
  });
  group('AvoidMountedInSetStateRule', () {
    test('reports using mounted in a setState callback', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if (mounted) {
            // Do something
          }
        });
      },
      child: Text('Press me'),
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidMountedInSetStateRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does not report a setState callback without mounted', () async {
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

      final diagnostics = runAnalysisRuleOnUnit(AvoidMountedInSetStateRule(), unit);

      expect(diagnostics, isEmpty);
    });
  });
}
