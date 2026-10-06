import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/flutter/avoid_watch_outside_build_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidWatchOutsideBuildRule', () {
    test('reports watch(context) called in a custom method outside build', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  void myMethod(BuildContext context) {
    context.watch(someProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Text('Hello');
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidWatchOutsideBuildRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does not report watch(context) in build method', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final value = context.watch(someProvider);
    return Text(value);
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidWatchOutsideBuildRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report watch on non-BuildContext target', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  void myMethod() {
    someObject.watch(something);
  }

  @override
  Widget build(BuildContext context) {
    return Text('Hello');
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidWatchOutsideBuildRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report non-watch method calls', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  void myMethod(BuildContext context) {
    context.read(someProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Text('Hello');
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidWatchOutsideBuildRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report watch in non-Widget class', () async {
      final unit = await resolveSource('''
class MyClass {
  void myMethod(BuildContext context) {
    context.watch(someProvider);
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidWatchOutsideBuildRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('reports multiple watch calls in a custom method', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  void myMethod(BuildContext context) {
    context.watch(provider1);
    context.watch(provider2);
  }

  @override
  Widget build(BuildContext context) {
    return Text('Hello');
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidWatchOutsideBuildRule(), unit);

      expect(diagnostics, hasLength(2));
    });

    test('reports watch in initState (outside build method)', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
    context.watch(someProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Text('Hello');
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidWatchOutsideBuildRule(), unit);

      expect(diagnostics, hasLength(1));
    });
  });
}
