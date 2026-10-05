import 'package:flutter_test/flutter_test.dart';
import 'package:my_lints/src/rules/bloc/add_cubit_suffix_rule.dart';

import '../../rule_test_harness.dart';

void main() {
  group('AddCubitSuffixRule', () {
    test('exposes the expected diagnostic code', () {
      expect(AddCubitSuffixRule().diagnosticCode.name, 'add_cubit_suffix_rule');
    });

    test('reports Cubit subclasses without the Cubit suffix', () async {
      final unit = await resolveSource('''
abstract class Cubit<State> {}

class ProfileController extends Cubit<int> {}
class ProfileCubit extends Cubit<int> {}
class Repository {}
''', fileName: 'bloc_fixture.dart');

      final diagnostics = runAnalysisRuleOnUnit(AddCubitSuffixRule(), unit);

      expect(diagnostics.map((node) => node.toSource()), ['class ProfileController extends Cubit<int> {}']);
    });
  });
}
