import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/avoid_nested_bloc_provider_rule.dart';

import '../rule_test_harness.dart';

void main() {
  group('AvoidNestedBlocProviderRule', () {
    test('reports a nested BlocProvider', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
  
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyBloc(),
      child: BlocProvider(
        create: (context) => AnotherBloc(),
        child: ElevatedButton(
          onPressed: () {
            Future.delayed(Duration(seconds: 1));
          },
          child: Text('Press me'),
        ),
      ),
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidNestedBlocProviderRule(), unit);

      expect(diagnostics, hasLength(2));
    });

    test("does not report with MultiBlocProvider", () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MyBloc(),
        ),
        BlocProvider(
          create: (context) => AnotherBloc(),
        ),
      ],
      child: ElevatedButton(
        onPressed: () {
          Future.delayed(Duration(seconds: 1));
        },
        child: Text('Press me'),
      ),
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidNestedBlocProviderRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test("does not report with multiple separate BlocProviders", () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocProvider(
          create: (context) => MyBloc(),
          child: ElevatedButton(
            onPressed: () {
              Future.delayed(Duration(seconds: 1));
            },
            child: Text('Press me'),
          ),
        ),
        BlocProvider(
          create: (context) => AnotherBloc(),
          child: ElevatedButton(
            onPressed: () {
              Future.delayed(Duration(seconds: 1));
            },
            child: Text('Press me'),
          ),
        ),
      ],
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidNestedBlocProviderRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report a single BlocProvider', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyBloc(),
      child: ElevatedButton(
        onPressed: () {
          Future.delayed(Duration(seconds: 1));
        },
        child: Text('Press me'),
      ),
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidNestedBlocProviderRule(), unit);

      expect(diagnostics, isEmpty);
    });

    test('does not report when there are no BlocProviders', () async {
      final unit = await resolveSource('''
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Future.delayed(Duration(seconds: 1));
      },
      child: Text('Press me'),
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(AvoidNestedBlocProviderRule(), unit);

      expect(diagnostics, isEmpty);
    });
  });
}
