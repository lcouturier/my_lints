import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/flutter/avoid_unnecessary_gesture_detector_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AvoidUnnecessaryGestureDetectorRule', () {
    test('reports GestureDetector without any event handlers', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Text('Press me'),
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidUnnecessaryGestureDetectorRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does not report GestureDetector with onTap handler', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print('tapped'),
      child: Text('Press me'),
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidUnnecessaryGestureDetectorRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report GestureDetector with onLongPress handler', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => print('long pressed'),
      child: Text('Press me'),
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidUnnecessaryGestureDetectorRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report GestureDetector with onDoubleTap handler', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () => print('double tapped'),
      child: Text('Press me'),
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidUnnecessaryGestureDetectorRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report GestureDetector with multiple handlers', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print('tapped'),
      onLongPress: () => print('long pressed'),
      child: Text('Press me'),
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidUnnecessaryGestureDetectorRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report GestureDetector with onPanStart handler', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (_) => print('pan started'),
      child: Text('Press me'),
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidUnnecessaryGestureDetectorRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report GestureDetector with onScaleStart handler', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (_) => print('scale started'),
      child: Text('Press me'),
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidUnnecessaryGestureDetectorRule(), unit);

      expect(diagnostics, isEmpty);
    });
  });
}
