import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/flutter/prefer_no_spacing_over_divide_widgets_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferSpacingOverDivideWidgetsRule', () {
    test('reports Column with divideWidgets on children', () async {
      final unit = await resolveSource(r'''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Item 1'),
        Text('Item 2'),
      ].divideWidgets(const SizedBox(height: 8)),
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(PreferSpacingOverDivideWidgetsRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does not report Column with spacing property', () async {
      final unit = await resolveSource(r'''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: [
        Text('Item 1'),
        Text('Item 2'),
      ],
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(PreferSpacingOverDivideWidgetsRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report Column without divideWidgets', () async {
      final unit = await resolveSource(r'''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Item 1'),
        Text('Item 2'),
      ],
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(PreferSpacingOverDivideWidgetsRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report Row with divideWidgets (only Column)', () async {
      final unit = await resolveSource(r'''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Item 1'),
        Text('Item 2'),
      ].divideWidgets(const SizedBox(height: 8)),
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(PreferSpacingOverDivideWidgetsRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report non-Widget class with divideWidgets', () async {
      final unit = await resolveSource(r'''
class MyClass {
  void myMethod() {
    final list = [1, 2, 3];
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(PreferSpacingOverDivideWidgetsRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('reports multiple Column with divideWidgets', () async {
      final unit = await resolveSource(r'''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            Text('Item 1'),
            Text('Item 2'),
          ].divideWidgets(const SizedBox(height: 8)),
        ),
        Column(
          children: [
            Text('Item 3'),
            Text('Item 4'),
          ].divideWidgets(const SizedBox(height: 8)),
        ),
      ],
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(PreferSpacingOverDivideWidgetsRule(), unit);

      expect(diagnostics, hasLength(2));
    });

    test('does not report Column with divideWidgets using SizedBox without const', () async {
      final unit = await resolveSource(r'''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Item 1'),
        Text('Item 2'),
      ].divideWidgets(SizedBox(height: 8)),
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(PreferSpacingOverDivideWidgetsRule(), unit);

      expect(diagnostics, isEmpty);
    });
  });
}
