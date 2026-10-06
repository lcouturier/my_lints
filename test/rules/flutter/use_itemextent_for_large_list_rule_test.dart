import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/flutter/use_itemextent_for_large_list_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('UseItemextentForLargeListRule', () {
    test('reports ListView.builder without itemExtent or prototypeItem', () async {
      final unit = await resolveSource(r'''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 100,
      itemBuilder: (context, index) {
        return Text('Item $index');
      },
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(UseItemextentForLargeListRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('does not report ListView.builder with itemExtent', () async {
      final unit = await resolveSource(r'''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 100,
      itemExtent: 50.0,
      itemBuilder: (context, index) {
        return Text('Item $index');
      },
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(UseItemextentForLargeListRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report ListView.builder with prototypeItem', () async {
      final unit = await resolveSource(r'''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 100,
      prototypeItem: ListTile(title: Text('Prototype')),
      itemBuilder: (context, index) {
        return ListTile(title: Text('Item $index'));
      },
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(UseItemextentForLargeListRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report ListView.builder with both itemExtent and prototypeItem', () async {
      final unit = await resolveSource(r'''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 100,
      itemExtent: 50.0,
      prototypeItem: ListTile(title: Text('Prototype')),
      itemBuilder: (context, index) {
        return ListTile(title: Text('Item $index'));
      },
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(UseItemextentForLargeListRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('reports ListView (non-builder constructor) - current behavior', () async {
      final unit = await resolveSource(r'''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text('Item 1'),
        Text('Item 2'),
      ],
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(UseItemextentForLargeListRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('reports ListView.builder without itemBuilder parameter', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 100,
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(UseItemextentForLargeListRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test('reports multiple ListView.builder without itemExtent or prototypeItem', () async {
      final unit = await resolveSource(r'''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          itemCount: 100,
          itemBuilder: (context, index) => Text('Item $index'),
        ),
        ListView.builder(
          itemCount: 50,
          itemBuilder: (context, index) => Text('Item $index'),
        ),
      ],
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(UseItemextentForLargeListRule(), unit);

      expect(diagnostics, hasLength(2));
    });
  });
}
