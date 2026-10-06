import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/flutter/do_not_call_to_list_after_divide_widgets_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('DoNotCallToListAfterDivideWidgetsRule', () {
    test('reports divideWidgets().toList() in a Flutter Widget', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

extension DivideWidgetsExtension on List<Widget> {
  List<Widget> divideWidgets() => this;
}

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final widgets = [Text('Hello'), Text('World')];
    final divided = widgets.divideWidgets().toList();
    return Container(child: Column(children: divided));
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(DoNotCallToListAfterDivideWidgetsRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does not report divideWidgets() without toList() in a Flutter Widget', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

extension DivideWidgetsExtension on List<Widget> {
  List<Widget> divideWidgets() => this;
}

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final widgets = [Text('Hello'), Text('World')];
    final divided = widgets.divideWidgets();
    return Container(child: Column(children: divided));
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(DoNotCallToListAfterDivideWidgetsRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report divideWidgets().toList() in a non-Widget class', () async {
      final unit = await resolveSource('''
extension DivideWidgetsExtension on List<String> {
  List<String> divideWidgets() => this;
}

class NotAWidget {
  void someMethod() {
    final widgets = ['Hello', 'World'];
    final divided = widgets.divideWidgets().toList();
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(DoNotCallToListAfterDivideWidgetsRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report toList() without divideWidgets() in a Flutter Widget', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final widgets = [Text('Hello'), Text('World')];
    final list = widgets.toList();
    return Container(child: Column(children: list));
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(DoNotCallToListAfterDivideWidgetsRule(), unit);

      expect(diagnostics, isEmpty);
    });
  });
}
