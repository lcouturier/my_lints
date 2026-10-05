import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/bloc/prefer_bloc_extensions_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('PreferBlocExtensionsRule', () {
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
            BlocProvider.of<MyBloc>(context).update();
          },
          child: Text('Press me'),
        ),
      ),
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(PreferBlocExtensionsRule(), unit);

      expect(diagnostics, hasLength(1));
    });

    test("does not report when using context.read", () async {
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
          context.read<MyBloc>().update();
        },
        child: Text('Press me'),
      ),
    );
  }
}
''', useWorkspacePackages: true);

      final diagnostics = runAnalysisRuleOnUnit(PreferBlocExtensionsRule(), unit);

      expect(diagnostics, isEmpty);
    });
  });
}
